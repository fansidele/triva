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

@implementation TimeSliceAggregation (State)
- (void) timeSliceOfStateAt: (id) instance
    withType: (id) type
    withNode: (TimeSliceTree *) node
{
  NSMutableDictionary *timeSliceValues = nil;
  NSMutableDictionary *timeSliceColors = nil;
  NSMutableDictionary *timeSliceTypes = nil;
  NSMutableDictionary *timeSliceDurations = nil;
  NSEnumerator *en = nil;
  id ent = nil;

  //getting the existing timeSliceValues for this node
  timeSliceValues = [node timeSliceValues];  
  timeSliceColors = [node timeSliceColors];
  timeSliceTypes = [node timeSliceTypes];
  timeSliceDurations = [node timeSliceDurations];

  //intializing state values to zero (in timeSliveValues dict) if they do not exist yet
  NSArray *allValuesOfStateType = [self allValuesForEntityType: type];
  en = [allValuesOfStateType objectEnumerator];
  while ((ent = [en nextObject]) != nil) {
    NSString *currentValue = [timeSliceValues objectForKey: ent];
    if (!currentValue) {
      [timeSliceValues setObject: [NSNumber numberWithDouble: 0]
              forKey: ent];
    }
  }
  //setting colors for values of the entity type
  en = [allValuesOfStateType objectEnumerator];
  while ((ent = [en nextObject]) != nil) {
    [timeSliceColors setObject: [self colorForValue: ent
               ofEntityType: type]
      forKey: ent];
    [timeSliceTypes setObject: type forKey: ent];
  }

  double tsDuration = [sliceEndTime timeIntervalSinceDate: sliceStartTime];

  //integrating in time for the selected time slice
  en = [self enumeratorOfEntitiesTyped:type
    inContainer:instance
    fromTime: sliceStartTime
    toTime: sliceEndTime 
    minDuration:0];
  while ((ent = [en nextObject]) != nil) {
    NSDate *start = [ent startTime];
    NSDate *end = [ent endTime];
    NSString *name = [ent value]; //the name is the value of state

    //controlling the time-slice border
    start = [start laterDate: sliceStartTime];
    end = [end earlierDate: sliceEndTime];

    //calculting the duration and getting value
    double duration = [end timeIntervalSinceDate: start];

    if (considerExclusiveDuration){
      float exclusiveDuration = [ent exclusiveDuration];
      if (exclusiveDuration < duration){
        duration = exclusiveDuration;
      }
    }

    //integrating the value of state in time
    double integrated = 1 * duration; //value of state is 1
    integrated /= tsDuration; //normalizing to time-slice

    //getting the current value
    double value = [[timeSliceValues objectForKey: name]
          doubleValue];
    value += integrated;

    //saving in the timeSliceValues dict
    [timeSliceValues setObject: [NSNumber numberWithDouble: value]
            forKey: name];

    //getting current accumulated duration for this name
    if (value){
      double acc;
      acc = [[timeSliceDurations objectForKey: name]
          doubleValue];
      acc += duration;
      [timeSliceDurations setObject:
          [NSNumber numberWithDouble:acc]
        forKey: name];
    }
  }
}
@end
