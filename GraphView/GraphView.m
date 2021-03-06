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
#include "GraphView.h"

#define MAX_SIZE 100

@implementation GraphView
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    NSString *className = [[self class] description];
    [NSBundle loadGSMarkupNamed: className owner: self];
  }
  [view setFilter: self];
  [window initializeWithDelegate: self];
  [window makeFirstResponder: view];

  slidersCreated = NO;

  //the graph representaiton
  graph = [[NSMutableDictionary alloc] init];

  //The tupi layout (the manager of all particles)
  tupiLayout = [[Layout alloc] init];
  return self;
}

- (void) startThread
{
  //the force-directed algorithm runner of Tupi
  runner = [[LayoutRunner alloc] init];
  [runner setLayout: tupiLayout];
  [runner setProvider: self];

  layoutThread = [[NSThread alloc] initWithTarget: runner
                                         selector: @selector(run:)
                                           object: nil];
  [layoutThread start];
}

- (void) stopThread
{
  if ([layoutThread isExecuting]){
    [layoutThread cancel];

    [runner release];
    runner = nil;
    [layoutThread release];
    layoutThread = nil;
  }
}

+ (NSDictionary *) defaultOptions
{
  NSBundle *bundle = [NSBundle bundleForClass: [self class]];
  NSString *className = [[self class] description];
  NSString *file = [bundle pathForResource: className
                                    ofType: @"plist"];
  return [NSDictionary dictionaryWithContentsOfFile: file];
}

- (void) setConfiguration: (TrivaConfiguration*) conf
{
  //extract my configuration and put in myOptions dictionary
  NSDictionary *myOptions = [conf configuredOptionsForClass: [self class]];

  //configure myself using the configuration in myOptions
  NSEnumerator *en = [myOptions keyEnumerator];
  NSString *key;
  while ((key = [en nextObject])){
  }
}

- (void) createScaleSliders
{
  if (slidersCreated) return;

  scaleSliders = [[NSMutableDictionary alloc] init];
  scaleLabels = [[NSMutableDictionary alloc] init];
  NSEnumerator *en = [[self graphConfiguration] keyEnumerator];
  NSString *confName;
  while ((confName = [en nextObject])){
    NSRect frame = NSMakeRect(0,0,80,16);

    frame.size = [confName sizeWithAttributes: nil];
    NSTextField *t = [[NSTextField alloc] initWithFrame: frame];
    [t setStringValue: confName];
    [t setEditable:NO];
    [t setBezeled:NO];
    [t setDrawsBackground:NO];
    [t setSelectable:NO];
    [scaleBox addView: t];
    [scaleBox setMinimumSize: frame.size forView: t];
    [t release];

    double confTraceMaxSize = [tree sizeForConfigurationName: confName];

    double max_size = MAX_SIZE/confTraceMaxSize;

    frame = NSMakeRect(0,0,80,16);
    NSSlider *slider = [[NSSlider alloc] initWithFrame: frame];
    [slider setMinValue: 0];
    [slider setMaxValue: 10*max_size];
    [slider setDoubleValue: max_size];
    [slider setTarget: self];
    [slider setAction: @selector(updateScaleSliders:)];
    [scaleBox addView: slider];
    [scaleBox setMinimumSize: frame.size forView: slider];
    [scaleSliders setObject: slider forKey: confName];
    [slider release];

    frame = NSMakeRect(0,0,50,16);
    NSTextField *l = [[NSTextField alloc] initWithFrame: frame];
    [l setStringValue: @"1"];
    [l setEditable:NO];
    [l setBezeled:NO];
    [l setDrawsBackground:NO];
    [l setSelectable:NO];
    [scaleBox addView: l];
    [scaleBox setMinimumSize: frame.size forView: l];
    [scaleLabels setObject: l forKey: confName];
    [l release];
  }

  [scaleBox sizeToFitContent];
  [mainVBox setMinimumSize: [scaleBox frame].size forView: scaleBox];
  [[mainVBox window] setContentSize: [mainVBox frame].size];

  [self updateScaleSliders: self];

  slidersCreated = YES;
}

- (void) dealloc
{
  [super dealloc];
}

- (TrivaGraph*) tree
{
  return tree;
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

- (BOOL) shouldBePresent: (PajeEntityType *) containerType
{
  NSSet *nodeTypes = [NSSet setWithArray: [self entityTypesForNodes]];

  //first, a direct check
  if ([nodeTypes containsObject: [containerType description]]){
    return YES;
  }

  //check if the children entity types are present
  NSEnumerator *en = [[self containedTypesForContainerType: containerType]
                       objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject])){
    if ([self shouldBePresent: type]){
      return YES;
    }
  }
  return NO;
}

- (TrivaGraph*) treeWithContainer: (PajeContainer *) cont
                           depth: (int) depth
                          parent: (TrivaTree*) p
{
  //filter by entity type
  if (![self shouldBePresent: [cont entityType]]){
    return nil;
  }
  //creating hierarchical structure
  TrivaGraph *ret = [TrivaGraph nodeWithName: [cont name]
                                     depth: depth
                                    parent: p
                                  expanded: NO
                                 container: cont
                                    filter: self];

  NSArray *containedTypes;
  containedTypes = [self containedTypesForContainerType: [cont entityType]];
  NSEnumerator *en = [containedTypes objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      NSEnumerator *en0 = [self enumeratorOfContainersTyped:type
                                                inContainer:cont];
      PajeContainer *sub;
      while ((sub = [en0 nextObject]) != nil) {
        TrivaGraph *child = [self treeWithContainer: sub
                                             depth: depth+1
                                            parent: ret];
        if (child){
          [ret addChild: child];
        }
      }
    }
  }
  return ret;
}


- (void) interconnectTree: (TrivaGraph*)rootNode
           usingContainer: (PajeContainer*) cont
{
  NSSet *edgeSet = [NSSet setWithArray: [self entityTypesForEdges]];
  NSArray *containedTypes;
  containedTypes = [self containedTypesForContainerType: [cont entityType]];
  PajeEntityType *type;
  NSEnumerator *en = [containedTypes objectEnumerator];
  while ((type = [en nextObject])){
    if ([type isKindOfClass: [PajeLinkType class]] &&
        [edgeSet containsObject: [type description]]){

      //FIXME TODO: why -1 to 1 for finding links?
      NSDate *st = [NSDate dateWithTimeIntervalSinceReferenceDate: -1];
      NSDate *et = [NSDate dateWithTimeIntervalSinceReferenceDate: 1];
      NSEnumerator *en2 = [self enumeratorOfEntitiesTyped: type
                                              inContainer: cont
                                                 fromTime: st
                                                   toTime: et
                                              minDuration: 0];
      PajeEntity *entity;
      while ((entity = [en2 nextObject])){
        TrivaGraph *s, *d;
        s = (TrivaGraph*)[rootNode searchChildByName:
                                     [[entity sourceContainer] name]];
        d = (TrivaGraph*)[rootNode searchChildByName:
                                     [[entity destContainer] name]];
        [s connectToNode: d];
        [d connectToNode: s];
      }
    }
  }

  //recurse
  en = [containedTypes objectEnumerator];
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      NSEnumerator *en0 = [self enumeratorOfContainersTyped:type
                                                inContainer:cont];
      PajeContainer *sub;
      while ((sub = [en0 nextObject]) != nil) {
        [self interconnectTree: rootNode
                usingContainer: sub];
      }
    }
  }
  return;
}

- (void) clearParticleSystem
{
  //clear everything
  [tupiLayout clear];
  [graph removeAllObjects];
}

- (void) startParticleSystem
{
  //first add all particles
  NSSet *nodes = [tree collapsedNodes];
  NSEnumerator *en = [nodes objectEnumerator];
  TrivaGraph *node;
  while ((node = [en nextObject])){
    NSPoint pos = [node location];
    if (NSEqualPoints (pos, NSZeroPoint)){
      pos = [(TrivaGraph*)[node parent] location];
    }
    pos.x += (2*drand48() - 1);
    pos.y += (2*drand48() - 1);

    //transform to tupi space
    pos.x /= 100;
    pos.y /= 100;

    //create the graph node
    GraphNode *n = [[GraphNode alloc] initWithTrivaNode: node];

    [graph setObject: n forKey: [node name]];

    [tupiLayout addNode: n
               withName: [node name]
           withLocation: pos];

    [n release];
  }

  en = [nodes objectEnumerator];
  while ((node = [en nextObject])){
    GraphNode *n = [graph objectForKey: [node name]];

    NSEnumerator *en2 = [[node connectedNodes] objectEnumerator];
    TrivaGraph *connected;
    while ((connected = [en2 nextObject])){
      GraphNode *nn = [graph objectForKey: [connected name]];

      [n->connected addObject: nn];
    }
  }
}


- (void) hierarchyChanged
{
  //stop thread
  [self stopThread];

  //clear particle system
  [self clearParticleSystem];

  //free previous tree
  [tree release];

  //create and interconnect new tree based on trace hierarchy/links
  tree = [self treeWithContainer: [self rootInstance] depth: 0 parent: nil];
  [self interconnectTree: tree usingContainer: [self rootInstance]];
  [tree retain];

  //gui stuff
  [self createScaleSliders];
  [self timeSelectionChanged];

  //checks
  [self startThread];

  //the particle system
  [self startParticleSystem];
}

- (void) timeSelectionChanged
{
  [tree timeSelectionChanged];
  [view setNeedsDisplay: YES];
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


- (void)windowDidMove:(NSNotification *)win
{
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}

- (void) show
{
  [window orderFront: self];
}

- (void) show: (id) sender
{
  [self show];
}


//from the view
- (void) clickNode: (TrivaGraph*) node
{
  //if node has no children, do nothing
  if (![[node children] count]){
    return;
  }

  //clear particle system
  [self clearParticleSystem];

  //expand the node
  [node expand];

  //remove the node from the particle system
  [self startParticleSystem];

  //redefine layout of the structure
  [tree recursiveLayout];

  //reset the view
  [view reset];
}

- (void) rightClickNode: (TrivaGraph*) node
{
  //if node has no parent, do nothing
  if (![node parent]){
    return;
  }

  [self clearParticleSystem];

  //collapse the parent node
  [(TrivaGraph*)[node parent] collapse];

  [self startParticleSystem];

  //redefine layout of the structure
  [tree recursiveLayout];

  //reset the view
  [view reset];
}

- (void) moveNode: (TrivaGraph*) node toLocation: (NSPoint) newLoc
{
  NSPoint tupiNewLocation = NSMakePoint(newLoc.x/100, newLoc.y/100);
  GraphNode *n = [graph objectForKey: [node name]];
  [tupiLayout moveNode: n toLocation: tupiNewLocation];
}

- (void) finishMoveNode: (TrivaGraph *) node
{
  GraphNode *n = [graph objectForKey: [node name]];
  [tupiLayout freezeNode: n frozen: NO];
}

- (void) clickForceDirected: (id) sender
{
  if ([layoutThread isExecuting]){
    [self stopThread];
  }else{
    [self startThread];
  }
}

/* resetting positions of everybody */
- (void) clickResetPositions: (id) sender
{
  [self hierarchyChanged];
}

- (void) updateScaleSliders: (id) sender
{
  NSEnumerator *en = [scaleSliders keyEnumerator];
  NSString *confName;
  while ((confName = [en nextObject])){
    NSSlider *slider = [scaleSliders objectForKey: confName];
    [[scaleLabels objectForKey: confName] setStringValue: 
                                            [slider stringValue]];
  }
  [tree recursiveLayout];
  [view setNeedsDisplay: YES];
}

- (double) scaleForConfigurationWithName: (NSString *) name
{
  if ([scaleSliders count] == 0) return 0;
  return [[scaleSliders objectForKey: name] doubleValue];
}

/* TupiProtocols */
- (void) layoutChanged
{
  [view setNeedsDisplay: YES];
}
@end
