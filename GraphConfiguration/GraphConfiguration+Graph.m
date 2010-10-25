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
  [edges release];

  if (graph){
    agclose (graph);
    graph = NULL;
  }

  [entities release];
}

- (BOOL) parseConfiguration: (NSDictionary *) conf
{
  nodes = [[NSMutableArray alloc] init];
  edges = [[NSMutableArray alloc] init];

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

- (BOOL) createGraphWithConfiguration: (NSDictionary*) conf
{
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
  NSEnumerator *en = NULL, *en2 = NULL;
  NSString *typeName;
  PajeEntityType *type;
  id n;
  id root = [self rootInstance]; //TODO: should I support children from others?

  //obtaining node type based on configuration, put instances on "nodes" attr
  en = [[conf objectForKey: @"node"] objectEnumerator];
  while ((typeName = [en nextObject])){
    [nodeTypes addObject: [self entityTypeWithName: typeName]];
  }
  en = [nodeTypes objectEnumerator];
  while ((type = [en nextObject])){
    en2 = [self enumeratorOfContainersTyped: type inContainer: root];
    while ((n = [en2 nextObject])){
      if (!userPositionEnabled && graphvizEnabled){
        agnode (graph, (char*)[[n name] cString]);
      }
      TrivaGraphNode *node = [[TrivaGraphNode alloc] init];
      [node setName: [n name]];
      [node setType: [type name]];
      [nodes addObject: node];

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
    }
  }

  //obtaining edge type based on configuration, put instances on "edges" attr
  en = [[conf objectForKey: @"edge"] objectEnumerator];
  while ((typeName = [en nextObject])){
    [edgeTypes addObject: [self entityTypeWithName: typeName]];
  }
  en = [edgeTypes objectEnumerator];
  while ((type = [en nextObject])){
    //check if edge is a link or container
    if ([type isKindOfClass: [PajeLinkType class]]){
      en2 = [self enumeratorOfEntitiesTyped: type
                                inContainer: root
                                   fromTime: [self startTime]
                                     toTime: [self endTime]
                                minDuration: 0];
    }else if ([type isKindOfClass: [PajeContainerType class]]){
      en2 = [self enumeratorOfContainersTyped: type
                                  inContainer: root];
    }
    while ((n = [en2 nextObject])){
      const char *src = NULL, *dst = NULL;
      //definition of source and destination of an edge 
      //if type is link, the source and destination are obtained directly
      //if type is container
      //        instance of the container must have fields "src" and "dst"
      //        that contain the name of the nodes this container edge connects 
      if ([type isKindOfClass: [PajeLinkType class]]){
        src = [[[n sourceContainer] name] cString];
        dst = [[[n destContainer] name] cString];
      }else if ([type isKindOfClass: [PajeContainerType class]]){
        NSString *fsrc, *fdst;
        fsrc = [[conf objectForKey: [type name]] objectForKey: @"src"];
        fdst = [[conf objectForKey: [type name]] objectForKey: @"dst"];
        src = [[n valueOfFieldNamed: fsrc] cString];
        dst = [[n valueOfFieldNamed: fdst] cString];
        if (!(src && dst)){
          PajeEntityType *source_type = [self entityTypeWithName: fsrc];
          NSEnumerator *en3 = [self enumeratorOfEntitiesTyped: source_type
                                                  inContainer: n
                                                     fromTime: 0
                                                       toTime: [self endTime]
                                                  minDuration: 0];
          NSString *source_hostname = [[en3 nextObject] value];

          PajeEntityType *destin_type = [self entityTypeWithName: fdst];
          NSEnumerator *en4 = [self enumeratorOfEntitiesTyped: destin_type
                                                  inContainer: n
                                                     fromTime: 0
                                                       toTime: [self endTime]
                                                  minDuration: 0];
          NSString *destin_hostname = [[en4 nextObject] value];
          src = [source_hostname cString];
          dst = [destin_hostname cString];
        }
      }

      if (!userPositionEnabled && graphvizEnabled){
        Agnode_t *s = agfindnode (graph, (char*)src);
        Agnode_t *d = agfindnode (graph, (char*)dst);
        if (!s || !d) continue; //ignore this edge completely
        agedge (graph, s, d);
      }

      TrivaGraphNode *sourceNode, *destNode;
      sourceNode = [self findNodeByName: [NSString stringWithFormat:@"%s",src]];
      destNode = [self findNodeByName: [NSString stringWithFormat:@"%s", dst]];

      TrivaGraphEdge *edge = [[TrivaGraphEdge alloc] init];
      [edge setName: [n name]];
      [edge setType: [type name]];
      [edge setSource: sourceNode];
      [edge setDestination: destNode];
      [edges addObject: edge];


      //add it to the entities dictionary
      NSMutableArray *array = [entities objectForKey: [type name]];
      if (array){
        [array addObject: edge];
      }else{
        array = [[NSMutableArray alloc] init];
        [array addObject: edge];
        [entities setObject: array forKey: [type name]];
        [array release];
      }


      [edge release];

      //to detect if there is more than one link 
      //between two TrivaGraphNode's
      [sourceNode addConnectedNode: destNode];
    }
  }

  [self definePositionWithConfiguration: conf];
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

NS_DURING
  if ([self retrieveGraphPositionsFromUserDefaults: [self traceUniqueLabel]]){
    return YES;
  }
NS_HANDLER
  NSLog (@"%@", localException);
  NSLog (@"Fallback is calculate positions with Graphviz.");
NS_ENDHANDLER

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
  [all addObjectsFromArray: edges];

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
