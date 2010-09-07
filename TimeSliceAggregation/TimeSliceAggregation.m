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
#include "TimeSliceAggregation.h"

@implementation TimeSliceAggregation
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
  }

  nodeNames = [[NSMutableDictionary alloc] init];

  /* starting configuration */
  considerExclusiveDuration = YES;
  tree = nil;
  graphAggregationEnabled = YES;
  
  return self;
}

- (void) dealloc
{
  [tree release];
  [nodeNames release];
  [super dealloc];
}

- (void) timeSliceAt: (id) instance
              ofType: (PajeEntityType*) type
            withNode: (TimeSliceTree *) node
{
  if ([type isKindOfClass: [PajeVariableType class]]){
    [self timeSliceOfVariableAt: instance
      withType: (PajeVariableType*)type
      withNode: node];
  }else if ([type isKindOfClass: [PajeStateType class]]){
    [self timeSliceOfStateAt: instance
      withType: (PajeStateType*)type
      withNode: node];
  }
  return;
}

- (TimeSliceTree *) createInstanceHierarchy: (id) instance
             parent: (TimeSliceTree *) parent
{
  TimeSliceTree *node = [[TimeSliceTree alloc] init];
  PajeEntityType *et = [self entityTypeForEntity: instance];
  [node setName: [instance name]];
  [node setParent: parent];
  //[node setPajeEntity: instance];
  if (parent != nil){
    [node setDepth: [parent depth] + 1];
  }else{
    [node setDepth: 0];
  }

  NSEnumerator *en;
  en = [[self containedTypesForContainerType:
    [self entityTypeForEntity:instance]] objectEnumerator];
  while ((et = [en nextObject]) != nil) {
    if ([self isContainerEntityType:et]) {
      NSEnumerator *en2;
      PajeContainer *sub;
      en2 = [self enumeratorOfContainersTyped: et
                inContainer:instance];
      while ((sub = [en2 nextObject]) != nil) {
        TimeSliceTree *child;
        child = [self createInstanceHierarchy: sub
              parent: node];
        [node addChild: child];
      }
    }else{
      [self timeSliceAt: instance ofType: et withNode: node];
    }
        }
  //saving node name in the nodeNames dict
  [nodeNames setObject: node forKey: [node name]];

  [node autorelease];
  return node;
}

- (void) releaseTree
{
  if (tree){
    [tree release];
    tree = nil;
    [nodeNames release];
    nodeNames = [[NSMutableDictionary alloc] init];
  }
}

- (void) calculateBehavioralHierarchy
{
//  NSLog (@"Calculating behavioral hierarchy...");
  /* re-create hierarchy */
  [self releaseTree];
  tree = [self createInstanceHierarchy: [self rootInstance]
              parent: nil];  

  if (graphAggregationEnabled){
    [self createGraphBasedOnLinks: [self rootInstance]
       withTree: tree];
  }

  [tree retain];
  /* aggregate values */
  [tree doAggregation];

  /* calculate the final value of the nodes (to be used by treemap)*/
  [tree doFinalValue];

  if (graphAggregationEnabled){
    [tree doGraphAggregationWithNodeNames: nodeNames];
  }
//  NSLog (@"Done");
}

-(void)timeSelectionChanged
{
  [self calculateBehavioralHierarchy];
  [super timeSelectionChanged];
}

- (void) entitySelectionChanged
{
  [self calculateBehavioralHierarchy];
  [super entitySelectionChanged];
}

- (void) containerSelectionChanged
{
  [self calculateBehavioralHierarchy];
  [super containerSelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
  [self calculateBehavioralHierarchy];
  [super dataChangedForEntityType: type];
}

- (TimeSliceTree *) timeSliceTree
{
  return tree;
}
@end
