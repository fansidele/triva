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
#include "TimeSliceDifTree.h"
#include <float.h>

@implementation TimeSliceDifTree
- (id) initWithTree: (TimeSliceTree*) tree
{
  self = [super init];

  dif = [[NSMutableDictionary alloc] init];
  mergedTree = NO;

  [self setName: [tree name]];
  [self setParent: [tree parent]];
  [self setDepth: [tree depth]];
  [self setMaxDepth: [tree maxDepth]];

  [[self timeSliceValues] addEntriesFromDictionary: [tree timeSliceValues]];
  [[self timeSliceTypes] addEntriesFromDictionary: [tree timeSliceTypes]];
  [[self timeSliceColors] addEntriesFromDictionary: [tree timeSliceColors]];
  [[self timeSliceDurations]addEntriesFromDictionary:[tree timeSliceDurations]];
  [[self aggregatedValues] addEntriesFromDictionary: [tree aggregatedValues]];
  [self setFinalValue: [tree finalValue]];

  //copying hierarchy
  NSEnumerator *en = [[tree children] objectEnumerator];
  id child;
  while ((child = [en nextObject])){
    TimeSliceDifTree *childcopy = [[TimeSliceDifTree alloc] initWithTree:child];
    [self addChild: childcopy];
    [childcopy release];
  }
  return self;
}

- (void) dealloc
{
  [dif release];
  [super dealloc];
}

- (void) subtractTree: (TimeSliceTree*) tree
{
  mergedTree = YES;

  //recurse
  int i;
  for (i = 0; i < [children count]; i++){
    TimeSliceDifTree *child = [children objectAtIndex: i];
    TimeSliceTree *treeChild = [[tree children] objectAtIndex: i];
    [child subtractTree: treeChild];
  }

  //calculating differences
  NSDictionary *tA = [self timeSliceValues];
  NSDictionary *tB = [tree timeSliceValues];

  NSMutableDictionary *newTSV; //TSV: TimeSliceValues
  newTSV = [[NSMutableDictionary alloc] init];

  id variable;
  NSEnumerator *en = [tA keyEnumerator];
  while ((variable = [en nextObject])){
    double vA = [[tA objectForKey: variable] doubleValue];
    double vB = [[tB objectForKey: variable] doubleValue];
    double vdif = vA - vB;

    //save original values
    NSString *variableA, *variableB;
    variableA = [NSString stringWithFormat: @"A_%@", variable];
    variableB = [NSString stringWithFormat: @"B_%@", variable];

    [newTSV setObject: [NSNumber numberWithDouble: vA]
               forKey: variableA];
    [newTSV setObject: [NSNumber numberWithDouble: vB]
               forKey: variableB];

    //saving absolute difference
    [newTSV setObject: [NSNumber numberWithDouble: abs(vdif)]
               forKey: variable];
   
    //register for which side is the difference 
    if (vdif > 0) {
      [dif setObject: @"1" forKey: variable];
    }else if (vdif < 0){
      [dif setObject: @"-1" forKey: variable];
    }else{
      [dif setObject: @"0" forKey: variable];
    }
  }
  [self setTimeSliceValues: newTSV];
  [newTSV release];
}

- (void) ratioTree: (TimeSliceTree*) tree
{
  mergedTree = YES;

  //recurse
  int i;
  for (i = 0; i < [children count]; i++){
    TimeSliceDifTree *child = [children objectAtIndex: i];
    TimeSliceTree *treeChild = [[tree children] objectAtIndex: i];
    [child ratioTree: treeChild];
  }

  //calculating differences
  NSDictionary *tA = [self timeSliceValues];
  NSDictionary *tB = [tree timeSliceValues];

  NSMutableDictionary *newTSV; //TSV: TimeSliceValues
  newTSV = [[NSMutableDictionary alloc] init];

  id variable;
  NSEnumerator *en = [tA keyEnumerator];
  while ((variable = [en nextObject])){
    double vA = [[tA objectForKey: variable] doubleValue];
    double vB = [[tB objectForKey: variable] doubleValue];

    //save original values
    NSString *variableA, *variableB;
    variableA = [NSString stringWithFormat: @"A_%@", variable];
    variableB = [NSString stringWithFormat: @"B_%@", variable];

    [newTSV setObject: [NSNumber numberWithDouble: vA]
               forKey: variableA];
    [newTSV setObject: [NSNumber numberWithDouble: vB]
               forKey: variableB];

    if (vA == 0 || vB == 0){
    }else{
      double ratio;
      if (vA > vB){
        ratio = 1 - vB/vA;
      }else{
        ratio = 1 - vA/vB;
      }
      //save ratio
      [newTSV setObject: [NSNumber numberWithDouble: ratio] 
                 forKey: variable];
    }
  }
  [self setTimeSliceValues: newTSV];
  [newTSV release];
}

- (NSMutableDictionary*) differences
{
  return dif;
}

- (BOOL) mergedTree
{
  return mergedTree;
}
@end
