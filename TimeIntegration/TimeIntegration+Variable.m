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
#include "TimeIntegration.h"

@implementation TimeIntegration (Variable)
- (void) timeSliceOfVariableAt: (id) instance
    withType: (PajeVariableType*) type
    withNode: (TimeSliceTree *) node
{
  NSDate *sliceStartTime = [self selectionStartTime];
  NSDate *sliceEndTime = [self selectionEndTime];
  double tsDuration = [sliceEndTime timeIntervalSinceDate: sliceStartTime];

  id ent = nil;
  double integrated = 0;
  NSEnumerator *en = [self enumeratorOfEntitiesTyped:type
    inContainer:instance
    fromTime: sliceStartTime
    toTime: sliceEndTime 
    minDuration:0];
  while ((ent = [en nextObject]) != nil) {
    NSDate *start = [ent startTime];
    NSDate *end = [ent endTime];

    //controlling the time-slice border
    start = [start laterDate: sliceStartTime];
    end = [end earlierDate: sliceEndTime];

    //calculting the duration and getting value
    double duration = [end timeIntervalSinceDate: start];
    double value = [[ent value] doubleValue];

    //integrating in time
    integrated += (duration/tsDuration) * value;
  }

  //registering on the node
  NSString *name = [type name]; //the name is the variable type name
  NSMutableDictionary *tsValues = [node timeSliceValues];
  NSMutableDictionary *tsColors = [node timeSliceColors];
  NSMutableDictionary *tsTypes = [node timeSliceTypes];
  [tsValues setObject: [NSNumber numberWithDouble: integrated] forKey: name];
  [tsColors setObject: [self colorForEntityType: type] forKey: name];
  [tsTypes setObject: type forKey: name];
}
@end
