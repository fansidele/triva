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

#define MAX_SIZE 400

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
  [self startForceDirectedThread];
  return self;
}


- (void) createScaleSliders
{
  static BOOL created = NO;
  if (created) return;

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

    frame = NSMakeRect(0,0,80,16);
    NSSlider *slider = [[NSSlider alloc] initWithFrame: frame];
    [slider setMinValue: 0];
    [slider setMaxValue: MAX_SIZE/confTraceMaxSize];
    [slider setDoubleValue: 2*MAX_SIZE/confTraceMaxSize];
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

  created = YES;
}

- (void) startForceDirectedThread
{
  executeThread = YES;
  lock = [[NSConditionLock alloc] initWithCondition: 0];
  thread = [[NSThread alloc] initWithTarget: self
                                   selector:
                               @selector(forceDirectedGraph:)
                                     object: nil];
  static int count = 0;
  [thread setName: [NSString stringWithFormat: @"t-%d", count++]];
  [thread start];
}

- (void) stopForceDirectedThread
{
  executeThread = NO;
}

- (void) dealloc
{
  executeThread = NO;
  [super dealloc];
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

  if ([self hasGraphvizLocationFromFile]){
    NSPoint p = [self graphvizLocationForName: [ret name]];
    NSSize size = [self graphvizSize];
    if (!NSEqualPoints(p, NSZeroPoint)){
      NSRect vb = [view bounds];
      p = NSMakePoint ((p.x/size.width) * vb.size.width,
                       (p.y/size.height) * vb.size.height);
      [ret setLocation: p];
      [ret setPositionsAlreadyCalculated: YES];
    }
  }

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

  [self createScaleSliders];
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
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  double total_energy = 0;
  NSDate *lastViewUpdate = [NSDate distantPast];
  do{ 
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
        double q1 = [c1 charge] * charge;
        double q2 = [c2 charge] * charge;
        double coulomb_repulsion = (coulomb_constant * (q1*q2)/(r*r));
        if (coulomb_repulsion > 100) coulomb_repulsion = 100;

        //hooke_attraction (-k * x)
        double hooke_attraction = 0;

        if ([c1 isConnectedTo: c2] ||
            [c2 isConnectedTo: c1]){
          //s should be smaller than one 
          double s = [c1 spring: c2] * spring;
          if (s < 1) s = 1;

          //hooke_attraction force should be maximum 100
          hooke_attraction = 1 - ((distance - s) / s);
          double m = 1;
          if (hooke_attraction < 0) m = -1;
          if (fabs(hooke_attraction) > 100) hooke_attraction = 100*m;
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
  if (executeThread){
    [self stopForceDirectedThread];
  }else{
    [self startForceDirectedThread];
  }
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

- (void) updateScaleSliders: (id) sender
{
  NSEnumerator *en = [scaleSliders keyEnumerator];
  NSString *confName;
  while ((confName = [en nextObject])){
    NSSlider *slider = [scaleSliders objectForKey: confName];
    [[scaleLabels objectForKey: confName] setStringValue: 
                                            [slider stringValue]];
  }
  [tree recursiveLayout3];
  [view setNeedsDisplay: YES];
}

- (double) scaleForConfigurationWithName: (NSString *) name
{
  if ([scaleSliders count] == 0) return 0;
  return [[scaleSliders objectForKey: name] doubleValue];
}

@end
