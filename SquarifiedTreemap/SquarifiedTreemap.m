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
#include <Renaissance/Renaissance.h>
#include "SquarifiedTreemap.h"

@implementation SquarifiedTreemap
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    [NSBundle loadGSMarkupNamed: @"SquarifiedTreemap" owner: self];
  }
  [view setFilter: self];
  [window initializeWithDelegate: self];
  [window makeFirstResponder: view];

  recordMode = NO;
  tree = nil;
  zType = GlobalZoom;
  return self;
}

- (TrivaTreemap*) treeWithContainer: (PajeContainer *) cont
                           depth: (int) depth
                          parent: (TrivaTree*) p
{
  TrivaTreemap *ret = [TrivaTreemap nodeWithName: [cont name]
                                     depth: depth
                                    parent: p
                                  expanded: NO
                                 container: cont
                                    filter: self];
  //creating hierarchical structure
  NSEnumerator *en = [[self containedTypesForContainerType: [cont entityType]] objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      NSEnumerator *en0 = [self enumeratorOfContainersTyped:type
                                                inContainer:cont];
      PajeContainer *sub;
      while ((sub = [en0 nextObject]) != nil) {
        TrivaTreemap *child = [self treeWithContainer: sub
                                             depth: depth+1
                                            parent: ret];
        [ret addChild: child];
      }
    }
  }
  return ret;
}

- (TrivaTreemap*) tree
{
  return tree;
}

- (void) timeSelectionChanged
{
  [view setNeedsDisplay: YES];
  [tree timeSelectionChanged];

  if (recordMode){
    [view printTreemap];
  }
}

- (void) hierarchyChanged
{
  [tree release];
  tree = [self treeWithContainer: [self rootInstance]
                           depth: 0
                          parent: nil];
  [tree retain];
  [view resetCurrentRoot];
  [self timeSelectionChanged];
}

- (void) entitySelectionChanged
{
  [self hierarchyChanged];
}

- (void) containerSelectionChanged
{
  [self hierarchyChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
  [self hierarchyChanged];
}

- (void) entropyChanged
{
  [view setNeedsDisplay: YES];
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

- (void) globalZoom: (id) sender
{
  zType = GlobalZoom;
  [view resetHighlighted];
  [view setNeedsDisplay: YES];
}

- (void) localZoom: (id) sender
{
  zType = LocalZoom;
  [view resetHighlighted];
  [view setNeedsDisplay: YES];
}

- (void) entropyZoom: (id) sender
{
  zType = EntropyZoom;
  [view resetHighlighted];
  [view setNeedsDisplay: YES];
}

- (ZoomType) zoomType
{
  return zType;
}
@end
