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
  forceDirectedNodes = [[NSMutableSet alloc] init];
  forceDirectedIgnoredNodes = [[NSMutableSet alloc] init];

  [self updateLabels: self];
  [self startThread];

  return self;
}

- (void) startThread
{
  executeThread = YES;
  pauseThread = NO;
  lock = [[NSConditionLock alloc] initWithCondition: 0];
  thread = [[NSThread alloc] initWithTarget: self
                                   selector:
                               @selector(forceDirectedGraph:)
                                     object: nil];
  static int count = 0;
  [thread setName: [NSString stringWithFormat: @"t-%d", count++]];
  [thread start];
}

- (void) dealloc
{
  executeThread = NO;
  [super dealloc];
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
  //TODO: Create a hierarchical structure that contains
  //only the types listed in the graphConfiguration
  //NSSet *nodeEntityTypeSet = [NSSet setWithArray: [self entityTypesForNodes]];

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
        [ret addChild: child];
      }
    }
  }
  return ret;
}


- (void) interconnectTree: (TrivaGraph*)rootNode
           usingContainer: (PajeContainer*) cont
{
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
        [self interconnectTree: rootNode
                usingContainer: sub];
      }
    }else{
      NSSet *edgeSet = [NSSet setWithArray: [self entityTypesForEdges]];
      if ([edgeSet containsObject: [type description]]){
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
  }
  return;
}

- (void) hierarchyChanged
{
  [forceDirectedNodes removeAllObjects];

  [tree release];
  tree = [self treeWithContainer: [self rootInstance]
                           depth: 0
                          parent: nil];
  [self interconnectTree: tree
          usingContainer: [self rootInstance]];
  [tree retain];
/*
  [self initializeGraphviz];
  [tree graphvizCreateNodes];
  [tree graphvizCreateEdges];
  [self layoutGraphviz];
  [tree graphvizSetPositions];
  [self finalizeGraphviz];
*/
  [tree setVisible: YES];
  [tree setChildrenVisible: NO];
  [view resetCurrentRoot];
  [self timeSelectionChanged];
}

- (void) timeSelectionChanged
{
  [view setNeedsDisplay: YES];
  [tree timeSelectionChanged];
  [tree recursiveLayout];
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


- (void) forceDirectedGraph: (id) sender
{
  NSLog (@"%s started", __FUNCTION__);
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  double total_energy = 0;
  NSDate *lastViewUpdate = [NSDate distantPast];
  do{ 
    if (pauseThread) continue;
    double spring = [springSlider floatValue];
    double charge = [chargeSlider floatValue];
    double damping = [dampingSlider floatValue];

    NSAutoreleasePool *p2 = [[NSAutoreleasePool alloc] init];
    NSPoint energy = NSMakePoint (0,0);

    //get lock
    [lock lock];

    NSEnumerator *en1 = [forceDirectedNodes objectEnumerator];
    TrivaGraph *c1;
    while ((c1 = [en1 nextObject])){
      NSPoint force = NSMakePoint (0, 0);

      //see the influence of everybody over c1, register in force
      NSEnumerator *en2 = [forceDirectedNodes objectEnumerator];
      TrivaGraph *c2;
      while ((c2 = [en2 nextObject])){
        if ([[c1 name] isEqualToString: [c2 name]]) continue;

        //calculating distance between particles
        NSPoint c1p = [c1 location];
        NSPoint c2p = [c2 location];
        double distance = LMSDistanceBetweenPoints (c1p, c2p);

        //coulomb_repulsion (k_e * (q1 * q2 / r*r))
        double coulomb_constant = 1;
        double r = distance==0 ? 1 : distance;
        double q1 = charge;
        double q2 = charge;
        double coulomb_repulsion = (coulomb_constant * (q1*q2)/(r*r));
        if (coulomb_repulsion > 100) coulomb_repulsion = 100;

        //hooke_attraction (-k * x)
        double hooke_attraction = 0;
        if ([c1 isConnectedTo: c2]){
          hooke_attraction = 1 - ((distance - spring) / spring);
        }

        //calculating direction of the effects
        NSPoint direction = LMSNormalizePoint(NSSubtractPoints(c1p, c2p));
        if (NSEqualPoints(direction, NSZeroPoint)){
          double x = (drand48()*2)-1;
          double y = (drand48()*2)-1;
          direction = NSMakePoint(x,y);
        }

        //applying calculated values
        force = NSAddPoints (force, LMSMultiplyPoint(direction,
                                                     coulomb_repulsion));
        force = NSAddPoints (force, LMSMultiplyPoint(direction,
                                                     hooke_attraction));
      }

      NSPoint velocity = [c1 velocity];
      velocity = NSAddPoints (velocity, force);
      velocity = LMSMultiplyPoint (velocity, damping);
      [c1 setVelocity: velocity];

      //set location of child c1
      NSPoint c1loc = [c1 location];
      c1loc = NSAddPoints (c1loc, velocity);
      if (![forceDirectedIgnoredNodes containsObject: c1]){
        [c1 setLocation: c1loc];
      }

      energy = NSAddPoints (energy, velocity);
    }

    //unlock
    [lock unlock];

    total_energy = fabs(energy.x) + fabs(energy.y);

    //update view?
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow: 0];
    double difTime = [now timeIntervalSinceDate: lastViewUpdate];
    if (difTime > 0.1){
      [lastViewUpdate release];
      lastViewUpdate = now;
      [view setNeedsDisplay: YES];
    }
    [lastViewUpdate retain];

    [p2 release];
    
  }while(executeThread);
  NSLog (@"%s stopped", __FUNCTION__);
  [pool release];
}

- (void) removeForceDirectedNode: (TrivaGraph*) n
{
  [lock lock];
  [forceDirectedNodes removeObject: n];
  [lock unlock];
}

- (void) removeForceDirectedIgnoredNode: (TrivaGraph*) n
{
  [forceDirectedIgnoredNodes removeObject: n];
  NSLog (@"%@", forceDirectedIgnoredNodes);
}

- (void) addForceDirectedNode: (TrivaGraph*) n
{
  [lock lock];
  [forceDirectedNodes addObject: n];
  [lock unlock];
}

- (void) addForceDirectedIgnoredNode: (TrivaGraph*) n
{
  [forceDirectedIgnoredNodes addObject: n];
}

- (void) removeForceDirectedNodes
{
  [lock lock];
  [forceDirectedNodes removeAllObjects];
  [lock unlock];
}

- (void) forceDirected: (id) sender
{
  pauseThread = !pauseThread;
}

- (void) updateLabels: (id) sender
{
  [springLabel setFloatValue: [springSlider floatValue]];
  [chargeLabel setFloatValue: [chargeSlider floatValue]];
  [dampingLabel setFloatValue: [dampingSlider floatValue]];
}

/* resetting positions of everybody */
- (void) resetPositions: (id) sender
{
  [lock lock];
  [tree recursiveResetPositions];
  [lock unlock];
}
@end
