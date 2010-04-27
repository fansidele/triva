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

@implementation TimeSliceAggregation (Debugging)
- (void) debug
{
  GSDebugAllocationActive(YES);
  Class *x = GSDebugAllocationClassList();
  int i = 0;
  while (1&&x[i]){
     NSLog (@"%@ - %d\n", x[i],
     GSDebugAllocationPeak(x[i]));
     i++;
  }
}

- (void) activateRecordingOfClass: (NSString *)classname
{
  Class *x = GSDebugAllocationClassList();
  int i = 0;
  while (1&&x[i]){
     if ([[x[i] description] isEqualToString: classname]){
         GSDebugAllocationActiveRecordingObjects(x[i]);
     }
     i++;
  }
}

- (void) listRecordedObjectsOfClass: (NSString *) classname
{
  Class *x = GSDebugAllocationClassList();
  int i = 0;
  while (1&&x[i]){
     if ([[x[i] description] isEqualToString: classname]){
         NSLog (@"%@ => %d (peak:%d)", x[i],
         [[[GSDebugAllocationListRecordedObjects(x[i])
           objectEnumerator]
         allObjects] count],
         GSDebugAllocationPeak(x[i]));
         NSEnumerator *en;
         en =[GSDebugAllocationListRecordedObjects(x[i])
           objectEnumerator];
         id obj;
         while ((obj = [en nextObject])){
          NSLog (@"\t%@", obj);
         }
     }
     i++;
  }
}

- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container
{
  NSLog (@"DEBUG START");
  NSLog (@"slice (%@ - %@)", sliceStartTime, sliceEndTime);
  NSLog (@"type = %@ container = %@", [type name], [container name]);
  NSEnumerator *en;
  id ent;
  en = [self enumeratorOfEntitiesTyped:type
    inContainer: container
    fromTime: sliceStartTime
    toTime: sliceEndTime 
    minDuration:0];
  double integrated = 0;
  while ((ent = [en nextObject]) != nil) {
    NSDate *start = [ent startTime];
                NSDate *end = [ent endTime];

                //controlling the time-slice border
                start = [start laterDate: sliceStartTime];
                end = [end earlierDate: sliceEndTime];

    double value = [[ent value] doubleValue];
    double duration = [end timeIntervalSinceDate: start];
    integrated += duration * value;

//    NSLog (@"\tint(%@ - %@) dur = %f val = %f",
    if(value){
    NSLog (@"\tdur = %f val = %f",
//      start, end, duration, value);
      duration, value);
    }
  }
  NSLog (@"integrated value = %f", integrated);
  NSLog (@"DEBUG END");
}
@end
