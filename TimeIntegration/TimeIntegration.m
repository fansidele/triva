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

@implementation TimeIntegration
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    colors = [[NSMutableDictionary alloc] init];
  }
  considerExclusiveDuration = YES;
  return self;
}

- (void) dealloc
{
  [colors release];
  [super dealloc];
}

- (NSDictionary *) timeIntegrationOfType:(PajeEntityType*) type
                             inContainer:(PajeContainer*) cont
{
  if ([type isKindOfClass: [PajeVariableType class]]){
    return [self timeIntegrationOfVariableType: type inContainer: cont];
  }else if ([type isKindOfClass: [PajeStateType class]]){
    return [self timeIntegrationOfStateType: type inContainer: cont];
  }else{
    //we don't time integrate links and events
    return [NSDictionary dictionary];
  }
}

- (NSDictionary *) timeIntegrationOfStateType: (PajeEntityType*) type
                                  inContainer: (PajeContainer *) instance
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSEnumerator *en = nil;
  id ent = nil;

  NSDate *sliceStartTime = [self selectionStartTime];
  NSDate *sliceEndTime = [self selectionEndTime];

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
    double value;
    if ([ret objectForKey: name] == nil){
      value = 0;
    }else{
      value = [[ret objectForKey: name] doubleValue];
    }
    value += integrated;

    //saving in the ret dict
    [ret setObject: [NSNumber numberWithDouble: value] forKey: name];
  }
  return ret;
}

- (NSDictionary *) timeIntegrationOfVariableType: (PajeEntityType *) type
                                     inContainer: (PajeContainer *) instance
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];

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

  NSString *variableIdent = [type description];
  [ret setObject: [NSNumber numberWithDouble: integrated]
                                      forKey: variableIdent];
  return ret;
}

- (void) setColorsForEntityType: (PajeEntityType*) containerType
{
  NSEnumerator *en = [[self containedTypesForContainerType: containerType]
                       objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      [self setColorsForEntityType: type];
    }else{
      if ([type isKindOfClass: [PajeVariableType class]]){
        [colors setObject: [self colorForEntityType: type]
                   forKey: [type description]];
      }else if ([type isKindOfClass: [PajeStateType class]]){
        //setting colors for values of the state type
        NSEnumerator *en2;
        id ent;
        en2 = [[self allValuesForEntityType: type] objectEnumerator];
        while ((ent = [en2 nextObject]) != nil) {
          [colors setObject: [self colorForValue: ent ofEntityType: type]
                     forKey: ent];
        }
      }else{
        //we don't set colors for links and events
      }
    }
  }
}

- (void) dataChangedForEntityType: (PajeEntityType*) type
{
  [self setColorsForEntityType: type];
  [super dataChangedForEntityType: type];
}

- (void) hierarchyChanged
{
  [self setColorsForEntityType: [[self rootInstance] entityType]];
  [super hierarchyChanged];
}

- (NSColor *) colorForIntegratedValueNamed: (NSString *) valueName
{
  return [colors objectForKey: valueName];
}
@end
