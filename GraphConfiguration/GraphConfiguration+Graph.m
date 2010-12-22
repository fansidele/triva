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

- (BOOL) createGraph
{
  NSLog (@"%s", __FUNCTION__);
  //configurationParsed should be YES when arrive here (won't check)
  //prefer user positions than those from graphviz

  NSMutableArray *nodeTypes = [NSMutableArray array];
  NSMutableArray *edgeTypes = [NSMutableArray array];
  NSEnumerator *en1 = NULL, *en2 = NULL;
  NSString *typeName;
  PajeEntityType *type;
  PajeEntity* entity;

  //transform the list given by the user on entity types
  en1 = [[manager nodeTypes] objectEnumerator];
  while ((typeName = [en1 nextObject])){
    NSArray *types = [self getTypeFrom: [[self rootInstance] entityType] withName: typeName];
    [nodeTypes addObjectsFromArray: types];
  }

  [manager startAdding];
  //for each type, iterate through its instances creating the TrivaGraphNodes of the graph
  en1 = [nodeTypes objectEnumerator];
  while ((type = [en1 nextObject])){
    en2 = [self enumeratorOfContainersTyped: type
                                inContainer: [self rootInstance]];
    while ((entity = [en2 nextObject])){
      [manager createNodeWithName: [entity name] type: [type name]];

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
*/
    }
  }

  //transform the list given by the user on entity types
  en1 = [[manager edgeTypes] objectEnumerator];
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
      Tupi *sourceNode, *destNode;
      sourceNode = [manager findNodeByName: [[entity sourceContainer] name]];
      destNode = [manager findNodeByName: [[entity destContainer] name]];
      [manager connectNode: sourceNode toNode: destNode];
    }
  }
  [manager endAdding];
  return YES;
}

/*
- (BOOL) definePositionWithConfiguration: (NSDictionary *) conf
{
  //recalculate position of all nodes and edges based on
  //1 - user provided positions if configuration has that
  //2 - user defaults (previous run of triva)
  //3 - graphviz if it was activated
  //4 - otherwise, return false

NS_DURING
  if ([manager userPosition]){
    if ([self retrieveGraphPositionsFromConfiguration: conf]){
      return YES;
    }
  }
NS_HANDLER
  NSLog (@"%@", localException);
  NSLog (@"Fallback is check positions from user defaults (previous run)");
NS_ENDHANDLER

  //last option is graphviz
  if ([manager graphviz]){
    if ([self retrieveGraphPositionsFromGraphviz: conf]){
      return YES;
    }
  }
  return YES;
}
*/

- (void) redefineLayout
{
  NSEnumerator *en = [manager enumeratorOfNodes];
  Tupi *node;
  while ((node = [en nextObject])){
    TimeSliceTree *nodeTree = [[self timeSliceTree]
                                        searchChildByName: [node name]];
    [manager layoutOfNode: node
               withValues: [nodeTree timeSliceValues]
                minValues: [[self timeSliceTree] minValues]
                maxValues: [[self timeSliceTree] maxValues]
                   colors: [nodeTree timeSliceColors]];
  }
}

/*
- (BOOL) redefineLayoutOf: (id) obj withConfiguration: (NSDictionary *) conf
{
  TimeSliceTree *tree = [self timeSliceTree];
  if (!tree){
    //FIXME
    NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
//    exit(1);
  }

  //getting values integrated within the time-slice
  NSDictionary *values = nil;
  NSDictionary *differences = nil;
  TimeSliceTree *objTree = [tree searchChildByName: [obj name]];
  if (!objTree){
    NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
//    exit(1);
  }else{
    values = [objTree timeSliceValues];

    //check to see if timeslicetree is a "merged" tree (with differences)
    if ([objTree isKindOfClass: [TimeSliceDifTree class]]){
      if ([objTree mergedTree]){
        differences = [objTree differences];
      }
    }

    //set timeSliceTree of the object TODO: remove this
    [obj setTimeSliceTree: objTree];
  }
  //position for object is already defined, let it calculate the rest
  //NSLog (@"[obj name] = %@, conf = %@ values = %@", [obj name], conf, values);
  if(![obj redefineLayoutWithConfiguration: conf
                              withProvider: self
                           withDifferences: differences
                        andTimeSliceValues: values]){
    NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
//    exit(1);
  }
  return YES;
}
*/
@end
