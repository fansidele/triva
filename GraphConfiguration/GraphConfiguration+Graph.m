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
#include "GraphConfiguration.h"

@implementation GraphConfiguration (Graph)
- (void) destroyGraph
{
  [nodes release];

  if (graph){
    agclose (graph);
    graph = NULL;
  }

  [entities release];
}

- (BOOL) parseConfiguration: (NSDictionary *) conf
{
  nodes = [[NSMutableArray alloc] init];

  graph = agopen ((char *)"graph", AGRAPHSTRICT);
  agnodeattr (graph, (char*)"label", (char*)"");
  agraphattr (graph, (char*)"overlap", (char*)"false");
  agraphattr (graph, (char*)"splines", (char*)"true");

  graphvizEnabled = NO;
  userPositionEnabled = NO;
  configurationParsed = NO;
  layoutRendered = NO;

  //dictionary to hold all TimeSlice entities used in graph
  entities = [[NSMutableDictionary alloc] init];

  if (!conf){
    return NO;
  }
 
  //check if graphviz should be used
  if ([conf objectForKey: @"graphviz-algorithm"]){
    graphvizEnabled = YES;
  }else{
    graphvizEnabled = NO;
  }

  //checking if user provided positions for nodes
  id area = [conf objectForKey: @"area"];
  if (area){
    userPositionEnabled = YES;
  }else{
    userPositionEnabled = NO;
  }

  configurationParsed = YES;

  NSLog (@"graphvizEnabled = %d", graphvizEnabled);
  NSLog (@"userPositionEnabled = %d", userPositionEnabled);
  NSLog (@"configurationParsed = %d", configurationParsed);
  return YES;
}

- (NSMutableArray*) getTypeFrom: (PajeEntityType*) type withName: (NSString*) name
{
  NSMutableArray *ret = [NSMutableArray array];

  if ([type isKindOfClass: [PajeContainerType class]]){
    NSEnumerator *en = [[self containedTypesForContainerType: type] objectEnumerator];
    PajeEntityType *childType;
    while ((childType = [en nextObject])){
      [ret addObjectsFromArray: [self getTypeFrom: childType withName: name]];
    }
  }
  if ([[type name] isEqualToString: name]){
    [ret addObject: type];
  }
  
  return ret;
}

- (BOOL) createGraphWithConfiguration: (NSDictionary*) conf
{
  //remove all existing nodes
  [nodes removeAllObjects];

  NSLog (@"%s", __FUNCTION__);
  //configurationParsed should be YES when arrive here (won't check)
  //prefer user positions than those from graphviz
  if (userPositionEnabled){
    NSDictionary *area = [conf objectForKey: @"area"];
    graphSize.origin.x = [[area objectForKey: @"x"] doubleValue];
    graphSize.origin.y = [[area objectForKey: @"y"] doubleValue];
    graphSize.size.width = [[area objectForKey: @"width"] doubleValue];
    graphSize.size.height = [[area objectForKey: @"height"] doubleValue];
  }

  NSMutableArray *nodeTypes = [NSMutableArray array];
  NSMutableArray *edgeTypes = [NSMutableArray array];
  NSEnumerator *en1 = NULL, *en2 = NULL;
  NSString *typeName;
  PajeEntityType *type;
  PajeEntity* entity;

  //obtaining node type based on configuration
  NSArray *node_types = [conf objectForKey: @"node"];
  if (!node_types || ![node_types isKindOfClass: [NSArray class]]){
    //FIXME
    NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
    exit(1);
  }

  //transform the list given by the user on entity types
  en1 = [node_types objectEnumerator];
  while ((typeName = [en1 nextObject])){
    NSArray *types = [self getTypeFrom: [[self rootInstance] entityType] withName: typeName];
    [nodeTypes addObjectsFromArray: types];
  }

  //for each type, iterate through its instances creating the TrivaGraphNodes of the graph
  en1 = [nodeTypes objectEnumerator];
  while ((type = [en1 nextObject])){
    en2 = [self enumeratorOfContainersTyped: type inContainer: [self rootInstance]];
    while ((entity = [en2 nextObject])){
      if (!userPositionEnabled && graphvizEnabled){
        agnode (graph, (char*)[[entity name] cString]);
      }
      TrivaGraphNode *node = [[TrivaGraphNode alloc] init];
      [node setName: [entity name]];
      [node setType: [type name]];
      [nodes addObject: node];

/*
      //add it to the entities dictionary
      NSMutableArray *array = [entities objectForKey: [type name]];
      if (array){
        [array addObject: node];
      }else{
        array = [[NSMutableArray alloc] init];
        [array addObject: node];
        [entities setObject: array forKey: [type name]];
        [array release];
      }
      [node release];
*/
    }
  }

  //obtaining edge type based on configuration
  NSArray *edge_types = [conf objectForKey: @"edge"];
  if (!edge_types || ![edge_types isKindOfClass: [NSArray class]]){
    //FIXME
    NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
    exit(1);
  }

  //transform the list given by the user on entity types
  en1 = [edge_types objectEnumerator];
  while ((typeName = [en1 nextObject])){
    NSArray *types = [self getTypeFrom: [[self rootInstance] entityType] withName: typeName];
    [edgeTypes addObjectsFromArray: types];
  }

  //for each edge type, iterate through its instances connecting the existing TrivaGraphNodes of the graph
  en1 = [edgeTypes objectEnumerator];
  while ((type = [en1 nextObject])){
    //check if edge is a link or container
    if (![type isKindOfClass: [PajeLinkType class]]){
      //FIXME
      NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
      exit(1);
    }

    //define slice of time to search for edges
    NSDate *start_slice, *end_slice;
    if ([[self selectionStartTime] isEqualToDate: [self startTime]]){
      //to get links that start and end at timestamp 0
      start_slice = [NSDate dateWithTimeIntervalSinceReferenceDate: -1];
    }else{
      start_slice = [self selectionStartTime];
    }
    if ([[self endTime] timeIntervalSinceReferenceDate] == 0){
      end_slice = [NSDate dateWithTimeIntervalSinceReferenceDate: 1];
    }else{
      end_slice = [self endTime];
    }

    //check if edge is a link or container
    NSEnumerator *en2 = [self enumeratorOfEntitiesTyped: type
                                inContainer: [self rootInstance]
                                   fromTime: start_slice
                                     toTime: end_slice
                                minDuration: 0];
    while ((entity = [en2 nextObject])){
      const char *src = NULL, *dst = NULL;
      src = [[[entity sourceContainer] name] cString];
      dst = [[[entity destContainer] name] cString];

      if (!userPositionEnabled && graphvizEnabled){
        Agnode_t *s = agfindnode (graph, (char*)src);
        Agnode_t *d = agfindnode (graph, (char*)dst);
        if (!s || !d) continue; //ignore this edge completely
        agedge (graph, s, d);
      }

      TrivaGraphNode *sourceNode, *destNode;
      sourceNode = [self findNodeByName: [NSString stringWithFormat:@"%s",src]];
      destNode = [self findNodeByName: [NSString stringWithFormat:@"%s", dst]];
      if (![[sourceNode name] isEqualToString: [destNode name]]){
        [sourceNode addConnectedNode: destNode];
        [destNode addConnectedNode: sourceNode];
      }
    }
  }

  [self definePositionWithConfiguration: conf];
//  [self saveGraphPositionsToUserDefaults: [self traceUniqueLabel]];
  return YES;
}

- (BOOL) definePositionWithConfiguration: (NSDictionary *) conf
{
  //recalculate position of all nodes and edges based on
  //1 - user provided positions if configuration has that
  //2 - user defaults (previous run of triva)
  //3 - graphviz if it was activated
  //4 - otherwise, return false

NS_DURING
  if (userPositionEnabled){
    if ([self retrieveGraphPositionsFromConfiguration: conf]){
      return YES;
    }
  }
NS_HANDLER
  NSLog (@"%@", localException);
  NSLog (@"Fallback is check positions from user defaults (previous run)");
NS_ENDHANDLER

/*
NS_DURING
  if ([self retrieveGraphPositionsFromUserDefaults: [self traceUniqueLabel]]){
    return YES;
  }
NS_HANDLER
  NSLog (@"%@", localException);
  NSLog (@"Fallback is calculate positions with Graphviz.");
NS_ENDHANDLER
*/

  //last option is graphviz
  if (graphvizEnabled){
    if ([self retrieveGraphPositionsFromGraphviz: conf]){
      return YES;
    }
  }
  return YES;
}

- (BOOL) redefineLayoutOfGraphWithConfiguration: (NSDictionary *) conf
{
  maxCache = [[NSMutableDictionary alloc] init];
  minCache = [[NSMutableDictionary alloc] init];

  NSMutableArray *all = [NSMutableArray array];
  [all addObjectsFromArray: nodes];

  NSEnumerator *en = [all objectEnumerator];
  id object;
  while ((object = [en nextObject])){
    NSString *type = [(TrivaGraphNode*)object type];
    NSDictionary *objectConf = [conf objectForKey: type];
    if (!objectConf) {
      return NO;
    }
    [self redefineLayoutOf: object withConfiguration: objectConf];
  }
  layoutRendered = YES;

  [maxCache release];
  [minCache release];
  return YES;
}

- (BOOL) redefineLayoutOf: (id) obj withConfiguration: (NSDictionary *) conf
{
  //getting values integrated within the time-slice
  id t = [[self timeSliceTree] searchChildByName: [obj name]];
  if (t == nil){
    NSLog (@"%s:%d The child %@ of TimeSliceTree (%@) does not "
            "exist.", __FUNCTION__, __LINE__, [obj name], [self timeSliceTree]);
    return NO;
  }
  NSMutableDictionary *values = [t timeSliceValues];

  //check to see if timeslicetree is a "merged" tree (with differences)
  NSDictionary *differences = nil;
  if ([t isKindOfClass: [TimeSliceDifTree class]]){
    if ([t mergedTree]){
      differences = [t differences];
    }
  }

  //set timeSliceTree of the object TODO: remove this
  [obj setTimeSliceTree: t];

  //position for object is already defined, let it calculate the rest
  //NSLog (@"[obj name] = %@, conf = %@ values = %@", [obj name], conf, values);
  if(![obj redefineLayoutWithConfiguration: conf
                              withProvider: self
                           withDifferences: differences
                        andTimeSliceValues: values]){
    return NO;
  }
  return YES;
}
@end
