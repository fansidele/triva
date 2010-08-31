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
  NSEnumerator *en = [timeSliceValues keyEnumerator];
  id key;
  while ((key = [en nextObject])){
    double val = [[timeSliceValues objectForKey: key] doubleValue];
    double treeVal = [[[tree timeSliceValues] objectForKey: key] doubleValue];
    double val_dif = val - treeVal;
    if (val_dif > 0) {
      [dif setObject: @"1" forKey: key];
      [timeSliceValues setObject: [NSNumber numberWithDouble: abs(val - treeVal)] forKey: key];
    }else if (val_dif < 0){
      [dif setObject: @"-1" forKey: key];
      [timeSliceValues setObject: [NSNumber numberWithDouble: abs(val - treeVal)] forKey: key];
    }else{
      [dif setObject: @"0" forKey: key];
    }
  }
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
