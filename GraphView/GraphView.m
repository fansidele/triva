/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GraphView.h"

@implementation GraphView
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    [NSBundle loadGSMarkupNamed: @"GraphView" owner: self];
  }
  [view setFilter: self];
  [window initializeWithDelegate: self];
  [window makeFirstResponder: view];
  gvc = NULL;
  graph = NULL;

  recordMode = NO;
  return self;
}

- (void) initializeGraphviz
{
  NSLog (@"%s", __FUNCTION__);
  //initialize graphviz
  gvc = gvContext();
  graph = agopen ((char *)"graph", AGRAPHSTRICT);
  agnodeattr (graph, (char*)"label", (char*)"");
  agraphattr (graph, (char*)"overlap", (char*)"false");
  agraphattr (graph, (char*)"splines", (char*)"true");
}

- (void) finalizeGraphviz
{
  NSLog (@"%s", __FUNCTION__);
  if (gvc) {
    gvFreeLayout (gvc, graph);
    agclose (graph);
    gvFreeContext (gvc);
  }
}

- (void) layoutGraphviz
{
  NSLog (@"%s", __FUNCTION__);
  if (gvc && graph){
    gvLayout (gvc, graph, "dot");
    gvRenderFilename (gvc, graph, "png", "x.png");
  }
}

- (TrivaGraph*) tree
{
  return tree;
}

- (graph_t *) graphviz
{
  return graph;
}

- (BOOL) hasContainerType: (NSArray *) containedTypes
{
  NSEnumerator *en = [containedTypes objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      return YES;
    }
  }
  return NO;
}

- (TrivaGraph*) treeWithContainer: (PajeContainer *) cont
                           depth: (int) depth
                          parent: (TrivaTree*) p
{
  //Create a hierarchical structure that contains
  //only the types listed in the graphConfiguration
  NSSet *nodeEntityTypeSet = [NSSet setWithArray: [self entityTypesForNodes]];


  NSArray *containedTypes;
  containedTypes = [self containedTypesForContainerType: [cont entityType]];
/*
  if ([self hasContainerType: containedTypes]){
    NSLog (@"%@ no children container types", [cont name]);
    //this is a leave node, before creating it
    //check if its type belongs to configured types
    if (![nodeEntityTypeSet containsObject: [[cont entityType] description]]){
      NSLog (@"should not create %@", cont);
      return nil;
    }
  }
*/

  //creating hierarchical structure
  TrivaGraph *ret = [TrivaGraph nodeWithName: [cont name]
                                     depth: depth
                                    parent: p
                                  expanded: NO
                                 container: cont
                                    filter: self];


  NSEnumerator *en = [containedTypes objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject])){
    //ignore if type does not belong to nodeEntityTypeSet (from graph configuration)
//    if (![nodeEntityTypeSet containsObject: [type description]]){
//      NSLog (@"%@ %@", nodeEntityTypeSet, type);
//      continue;
//    }

    if ([self isContainerEntityType: type]){
      NSEnumerator *en0 = [self enumeratorOfContainersTyped:type
                                                inContainer:cont];
      PajeContainer *sub;
      while ((sub = [en0 nextObject]) != nil) {
        TrivaGraph *child = [self treeWithContainer: sub
                                             depth: depth+1
                                            parent: ret];
        [ret addChild: child];
      }
    }
  }

  //connecting the dots
  NSSet *edgeEntityTypeSet = [NSSet setWithArray: [self entityTypesForEdges]];
  en = [[self containedTypesForContainerType: [cont entityType]] objectEnumerator];
  while ((type = [en nextObject])){
    if ([edgeEntityTypeSet containsObject: [type description]]){
      NSDate *start_slice = [NSDate dateWithTimeIntervalSinceReferenceDate: -1];
      NSDate *end_slice = [self endTime];
      NSEnumerator *en2 = [self enumeratorOfEntitiesTyped: type
                                inContainer: [self rootInstance]
                                   fromTime: start_slice
                                     toTime: end_slice
                                minDuration: 0];
      id entity;
      while ((entity = [en2 nextObject])){
        TrivaGraph *sourceNode, *destNode;
        sourceNode = [ret searchChildByName: [[entity sourceContainer] name]];
        destNode = [ret searchChildByName: [[entity destContainer] name]];
        [sourceNode connectToNode: destNode];
        [destNode connectToNode: sourceNode];
      }
    }
  }
  return ret;
}

- (void) hierarchyChanged
{
  [self finalizeGraphviz];
  [tree release];
  tree = [self treeWithContainer: [self rootInstance]
                           depth: 0
                          parent: nil];
  [tree retain];
  [self initializeGraphviz];
  [view resetCurrentRoot];
  [self timeSelectionChanged];
}

- (void) timeSelectionChanged
{
  [view setNeedsDisplay: YES];
  [tree timeSelectionChanged];
  [tree graphvizCreateNodes];
  [tree graphvizCreateEdges];
  [self layoutGraphviz];
  [tree graphvizSetPositions];
  if(recordMode){
    [view printGraph];
  }
}

- (void)windowDidMove:(NSNotification *)win
{
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}

- (void) setRecordMode
{
  recordMode = !recordMode;
  NSLog (@"recordMode set to %d", recordMode);
}

- (void) show
{
  [window orderFront: self];
}
@end
