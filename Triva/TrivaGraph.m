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
#include "TrivaGraph.h"
#include <float.h>

#define BIGFLOAT FLT_MAX

@implementation TrivaGraph
+ (TrivaGraph*) nodeWithName: (NSString*)n
                      depth: (int)d
                     parent: (TrivaTree*)p
                   expanded: (BOOL)e
                  container: (PajeContainer*)c
                     filter: (TrivaFilter*)f
{
  return [[[self alloc] initWithName: n
              depth:d
             parent:p
           expanded:e
          container:c
             filter:f] autorelease];
}


- (id) initWithName: (NSString*)n
              depth: (int)d
             parent: (TrivaTree*)p
           expanded: (BOOL)e
          container: (PajeContainer*)c
             filter: (TrivaFilter*)f
{
  self = [super initWithName:n
                       depth:d
                      parent:p
                    expanded:e
                   container:c
                      filter:f];
  if (self != nil){
    connectedNodes = [[NSMutableSet alloc] init];
    compositions = [[NSMutableDictionary alloc] init];

    //layout myself with update my graph values
    NSDictionary *configuration;
    configuration = [filter graphConfigurationForContainerType:
                              [container entityType]];

    //layout my compositions
    NSMutableArray *array;
    NSEnumerator *en;
    NSString *compositionName;

    array = [NSMutableArray arrayWithArray: [configuration allKeys]];
    en = [array objectEnumerator];
    while ((compositionName = [en nextObject])){
      NSDictionary *compConf = [configuration objectForKey: compositionName];
      if (![compConf isKindOfClass: [NSDictionary class]]) continue;
      if (![compConf count]) continue;

      //check if composition already exist
      TrivaComposition *comp = [compositions objectForKey: compositionName];
      if (!comp){
        comp = [TrivaComposition compositionWithConfiguration:compConf
                                                         name:compositionName
                                                       values:values
                                                         node:self
                                                       filter:filter];
        [compositions setObject: comp forKey: compositionName];
      }
    }

  }
  return self;
}

- (void) dealloc
{
  [connectedNodes release];
  [compositions release];
  //kill thread
  executeThread = NO;
  [thread cancel];
  [super dealloc];
}

- (void) connectToNode: (TrivaGraph*) n
{
  [connectedNodes addObject: n];
}

- (void) timeSelectionChanged
{
  [super timeSelectionChanged];

  // [self layout];

  //top-down
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child timeSelectionChanged];
  }

}

- (void) layout
{
  NSDictionary *minValues, *maxValues;
  minValues = [filter minValuesForContainerType: [container entityType]];
  maxValues = [filter maxValuesForContainerType: [container entityType]];

  //layout myself with update my graph values
  NSDictionary *configuration;
  configuration = [filter graphConfigurationForContainerType:
                            [container entityType]];
  if (configuration){
    //layout myself
    NSString *sizeConfiguration = [configuration objectForKey: @"size"];
    double screenSize;
    if ([self expressionHasVariables: sizeConfiguration]){
      double min = [self evaluateWithValues: minValues
                                   withExpr: sizeConfiguration];
      double max = [self evaluateWithValues: maxValues
                                   withExpr: sizeConfiguration];
      double dif = max - min;
      double val = [self evaluateWithValues: values
                                   withExpr: sizeConfiguration];
      if (dif != 0) {
        screenSize = MIN_SIZE + ((val - min)/dif)*(MAX_SIZE-MIN_SIZE);
      }else{
        screenSize = MIN_SIZE + ((val - min)/min)*(MAX_SIZE-MIN_SIZE);
      }
      size = val;
    }else{
      screenSize = [sizeConfiguration doubleValue];
    }

    [self layoutSizeWith: screenSize];
    [self layoutConnectionPointsWith: screenSize];


    NSLog (@"%@ %d", [self name], [connectedNodes count]);    

/*
    //layout my compositions 
    //update bounding boxes of compositions
    NSEnumerator *en = [compositions objectEnumerator];
    id comp;
    while ((comp = [en nextObject])){
      [comp setBoundingBox: bb];
      [comp timeSelectionChanged];
    }
*/
  }

}

- (void) graphvizSetPositions
{
  graph_t *mainGraph = [filter graphviz];
  graph_t *parentGraph = NULL;
  if (parent){
    NSMutableString *parentGraphName;
    parentGraphName = [NSMutableString stringWithString: @"cluster_"];
    [parentGraphName appendString: [parent name]];
    parentGraph = agfindsubg (mainGraph, (char*)[parentGraphName cString]);
  }else{
    parentGraph = mainGraph;
  }
  if ([children count]){
    //have children, add myself as a subgraph
    NSMutableString *graphvizName;
    graphvizName = [NSMutableString stringWithString: @"cluster_"];
    [graphvizName appendString: name];
    graph_t *graph = agfindsubg (parentGraph, (char*)[graphvizName cString]);

    NSRect newBB;
    newBB.origin.x = ((double)graph->u.bb.LL.x);
    newBB.origin.y = ((double)graph->u.bb.LL.y);
    newBB.size.width = ((double)graph->u.bb.UR.x) - newBB.origin.x;
    newBB.size.height = ((double)graph->u.bb.UR.y) - newBB.origin.y;
    [self setBoundingBox: newBB];
  }else{
    Agnode_t *node = agfindnode (parentGraph, (char*)[name cString]);
    NSRect newBB;
    newBB.origin.x = (double)ND_coord(node).x;
    newBB.origin.y = (double)ND_coord(node).y;
    if (bb.size.width == 0 && bb.size.height == 0){
      newBB.size.width = ND_bb(node).UR.x - newBB.origin.x;
      newBB.size.height = ND_bb(node).UR.y - newBB.origin.y;
    }else{
      newBB.size.width = bb.size.width;
      newBB.size.height = bb.size.height;
    }
    [self setBoundingBox: newBB];
  }
  
  //recurse among my children
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child graphvizSetPositions];
  }
}

- (void) graphvizCreateEdges
{
  graph_t *mainGraph = [filter graphviz];
  graph_t *parentGraph = NULL;
  if (parent){
    NSMutableString *parentGraphName;
    parentGraphName = [NSMutableString stringWithString: @"cluster_"];
    [parentGraphName appendString: [parent name]];
    parentGraph = agfindsubg (mainGraph, (char*)[parentGraphName cString]);
  }else{
    parentGraph = mainGraph;
  }
  if (!parentGraph){
    [[NSException exceptionWithName: @"graphvizCreateEdges" 
                             reason: @"parentGraph was not found"
                           userInfo: nil] raise];
  }

  if ([connectedNodes count]){
    Agnode_t *my_node = agfindnode (parentGraph, (char*)[name cString]);
    if (!my_node){
      [[NSException exceptionWithName: @"graphvizCreateEdges" 
                               reason: @"my_node is not created"
                             userInfo: nil] raise];
    }

    //connect the dots in graphviz
    NSEnumerator *en = [connectedNodes objectEnumerator];
    TrivaGraph *partner;
    while ((partner = [en nextObject])){
      Agnode_t *partner_node;
      partner_node = agfindnode (mainGraph, (char*)[[partner name] cString]);
      if (!partner_node){
        //exception, parentGraph should be always defined
        [[NSException exceptionWithName: @"graphvizCreateEdges" 
                                 reason: @"partner_node is not created"
                               userInfo: nil] raise];
      }
      agedge (mainGraph, my_node, partner_node);
    }
  }

  //recurse among my children
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child graphvizCreateEdges];
  }
  
}

- (void) graphvizCreateNodes
{
  //define parent graph (it has to be a subgraph, name starts as 'cluster_')
  graph_t *mainGraph = [filter graphviz];
  graph_t *parentGraph = NULL;
  if (parent){
    NSMutableString *parentGraphName;
    parentGraphName = [NSMutableString stringWithString: @"cluster_"];
    [parentGraphName appendString: [parent name]];
    parentGraph = agfindsubg (mainGraph, (char*)[parentGraphName cString]);
  }else{
    parentGraph = mainGraph;
  }

  if (parentGraph == NULL){
    //exception, parentGraph should be always defined
    [[NSException exceptionWithName: @"GraphVizCreateNode" 
                             reason: @"parentGraph is not created"
                           userInfo: nil] raise];
  }

  if ([children count]){
    //have children, add myself as a subgraph
    NSMutableString *graphvizName;
    graphvizName = [NSMutableString stringWithString: @"cluster_"];
    [graphvizName appendString: name];
    agsubg (parentGraph, (char*)[graphvizName cString]);
  }else{
    agnode (parentGraph, (char*)[name cString]);
 }

  //recurse among my children
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child graphvizCreateNodes];
  }
  return;
}

- (void) drawBorder
{
  [[NSColor blackColor] set];
  [NSBezierPath strokeRect: bb];
}

- (void) drawLayout
{
  //draw a line to connected nodes
  [[NSColor grayColor] set];
  NSEnumerator *en = [connectedNodes objectEnumerator];
  TrivaGraph *partner;
  while ((partner = [en nextObject])){
    NSPoint mp = [self connectionPointForPartner: partner];
    NSPoint pp = [partner connectionPointForPartner: self];

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: mp];
    [path lineToPoint: pp];
    [path stroke];
  }

  //compositions
  //draw my components
  en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [comp drawLayout];
  }

  //draw myself
  NSBezierPath *border = [NSBezierPath bezierPathWithRect: bb];
  if ([self highlighted]){
    NSString *str;
    str = [NSString stringWithFormat: @"%@(%@) - %f",
                    name,
                    [container entityType],
                    size];
    [str drawAtPoint: NSMakePoint (bb.origin.x,
                                   bb.origin.y+bb.size.height)
       withAttributes: nil];
  }
  [[NSColor grayColor] set];
  [border stroke];
}

/*
 * Search method
 */
- (TrivaGraph *) searchWith: (NSPoint) point
               limitToDepth: (int) d
{
  if ([self depth] == d){
    if (NSPointInRect (point, bb)){
      return self;
    }
  }else{
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      TrivaGraph *ret = [child searchWith: point limitToDepth: d];
      if (ret) return ret;
    }
  }
  return nil;
}

/* 
 * expressions
 */
- (BOOL) expressionHasVariables: (NSString*) expr
{
  BOOL ret;
  char **expr_names;
  int count;
  void *f = evaluator_create ((char*)[expr cString]);
  evaluator_get_variables (f, &expr_names, &count);
  if (count == 0){
    ret = NO;
  }else{
    ret = YES;
  }
  evaluator_destroy (f);
  return ret;
}

- (double) evaluateWithValues: (NSDictionary *) vals
    withExpr: (NSString *) expr
{
  char **expr_names;
  double *expr_values, ret;
  int count, i;
  void *f = evaluator_create ((char*)[expr cString]);
  evaluator_get_variables (f, &expr_names, &count);
  if (count == 0){
    //no variables detected, return doubleValue
    return [expr doubleValue];
  }else{
    //ok, we have some variables to be defined
    expr_values = (double*)malloc (count * sizeof(double));
    for (i = 0; i < count; i++){
      NSString *var = [NSString stringWithFormat: @"%s", expr_names[i]];
      NSString *val = [vals objectForKey: var];
      if (val){
        expr_values[i] = [val doubleValue];
      }else{
        static BOOL appeared = NO;
        if (!appeared){
          NSLog (@"%s:%d Expression (%@) has variables that are "
            "not present in the aggregated tree (%@). Considering "
            "that their values is zero. This message appears only once.",
            __FUNCTION__, __LINE__, expr, vals);
          appeared = YES;
        }
        expr_values[i] = 0;

      }
    }
    ret = evaluator_evaluate (f, count, expr_names, expr_values);
    evaluator_destroy (f);
    free(expr_values);
  }
  return ret;
}

- (NSPoint) centerPoint
{
  return NSMakePoint (bb.origin.x + bb.size.width/2,
                      bb.origin.y + bb.size.height/2);
}

- (void) setBoundingBox: (NSRect) nbb
{
  [super setBoundingBox: nbb];


}

- (NSSet*) connectedNodes;
{
  return connectedNodes;
}


- (double) forceDirectedChildrenLayout: (id) sender
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  //first, position children randomly withing a 100 x 100 points square
  NSEnumerator *en0 = [children objectEnumerator];
  TrivaGraph *c0;
  while ((c0 = [en0 nextObject])){
    NSRect b = [c0 boundingBox];
    b.origin = NSMakePoint (drand48()*100, drand48()*100);
    [c0 setBoundingBox: b];
    [c0 resetVelocity];
  }

  double total_energy = 0;

  do{ 
    NSAutoreleasePool *p2 = [[NSAutoreleasePool alloc] init];
    
    double spring = 100;
    double damping = 0.9;
    NSPoint total_kinetic_energy = NSMakePoint (0,0);

    NSEnumerator *en1 = [children objectEnumerator];
    TrivaGraph *c1;
    while ((c1 = [en1 nextObject])){
      NSPoint force = NSMakePoint (0, 0);

      //see the influence of everybody over me
      NSEnumerator *en2 = [children objectEnumerator];
      TrivaGraph *c2;
      while ((c2 = [en2 nextObject])){

        if (c1 == c2) continue;

        //calculating distance between particles
        NSPoint c1p = [c1 connectionPointForPartner: c2];
        NSPoint c2p = [c2 connectionPointForPartner: c1];
        NSPoint dif = NSSubtractPoints (c1p, c2p);
        double distance = LMSDistanceBetweenPoints (c1p, c2p);

        //coulomb_repulsion (k_e * (q1 * q2 / r*r))
        double coulomb_constant = 1;
        double r = distance;
        double q1 = 100;
        double q2 = 100;
        double coulomb_repulsion = coulomb_constant * (q1*q2)/(r*r);

        //hooke_attraction (-k * x)
        double hooke_attraction = 0;
        if ([[c1 connectedNodes] containsObject: c2]){
          hooke_attraction = 1 - (fabs (distance - spring) / spring);
        }

        //applying calculated values
        force = NSAddPoints (force,
                             LMSMultiplyPoint (LMSNormalizePoint(dif),
                                               coulomb_repulsion));
        force = NSAddPoints (force,
                             LMSMultiplyPoint (LMSNormalizePoint(dif),
                                               hooke_attraction));
      }

      //calculate my velocity
      NSPoint v = [c1 velocity];
      v = NSAddPoints (v, force);
      v = LMSMultiplyPoint (v, damping);
      [c1 setVelocity: v];

      total_kinetic_energy = NSAddPoints (total_kinetic_energy, v);

      //set origin of child c1
      NSRect c1bb = [c1 boundingBox];
      c1bb.origin = NSAddPoints (c1bb.origin, v);
      [c1 setBoundingBox: c1bb];
    }

    //calculate my bounding box depending on children's bb
    NSEnumerator *en0 = [children objectEnumerator];
    TrivaGraph *c0;
    NSRect myBB = NSZeroRect;
    while ((c0 = [en0 nextObject])){
      myBB = NSUnionRect ([c0 boundingBox], myBB);
    }
    //change size
    [self setBoundingBox: myBB];
    total_energy = fabs(total_kinetic_energy.x) + fabs(total_kinetic_energy.y);
    [p2 release];
  }while(total_energy > 0.0001 && executeThread);
  [pool release];
}

- (void) forceDirectedLayout //bottom-up
{
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child forceDirectedLayout];
  }

  [thread cancel];

  //layout myself if a have no children
  if ([children count] == 0){
    [self layout];
  }else{
    //calculate positions of my children in space
    //launch a thread to do it
    executeThread = YES;
    thread = [[NSThread alloc] initWithTarget: self
                                     selector:
                                 @selector(forceDirectedChildrenLayout:)
                                       object: nil];
    [thread start];
  }
}

- (void) resetVelocity
{
  velocity = NSZeroPoint;
}

- (void) setVelocity: (NSPoint)v
{
  velocity = v;
}

- (NSPoint) velocity
{
  return velocity;
}

- (void) cancelThreads
{
  executeThread = NO;
  [thread cancel];
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child cancelThreads];
  }
}
@end
