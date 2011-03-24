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
  [super dealloc];
}

- (void) connectToNode: (TrivaGraph*) n
{
  [connectedNodes addObject: n];
}

- (BOOL) isConnectedTo: (TrivaGraph*) c
{
  //return YES if connected directly to me 
  //or any of my children
  if ([connectedNodes containsObject: c]) return YES;
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    if ([child isConnectedTo: c]) return YES;
  }
  return NO;
}

- (void) timeSelectionChanged
{
  //update current values
  [super timeSelectionChanged];
}

/*
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
*/



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
 * Another search method: bottom-up search
 */
- (TrivaGraph *) searchAtPoint: (NSPoint) point
{
  if ([self expanded]){
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      TrivaGraph *ret = [child searchAtPoint: point];
      if (ret) return ret;
    }
  }else{
    if (NSPointInRect(point, bb)){
      return self;
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

- (void) recursiveResetPositions
{
  bb.origin = NSZeroPoint;

  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child recursiveResetPositions];
  }
}
@end
