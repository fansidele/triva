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

@implementation TimeIntegration (Link)
- (void) timeSliceOfLinkAt: (id) instance
    withType: (PajeLinkType*) type
    withNode: (TimeSliceTree *) node
{
  NSEnumerator *en = nil;
  id ent = nil;

  NSDate *sliceStartTime = [self selectionStartTime];
  NSDate *sliceEndTime = [self selectionEndTime];

  //integrating in time for the selected time slice
  en = [self enumeratorOfEntitiesTyped:type
    inContainer:instance
    fromTime: sliceStartTime
    toTime: sliceEndTime 
    minDuration:0];
  while ((ent = [en nextObject]) != nil) {
    NSString *source = [[ent sourceContainer] name];
    NSString *dest = [[ent destContainer] name];

    //getting source and dest nodes
    TimeSliceTree *sourceNode;
    TimeSliceTree *destNode;
    sourceNode = (TimeSliceTree*)[nodeNames objectForKey: source];
    destNode = (TimeSliceTree*)[nodeNames objectForKey: dest];

    //get edge for destNode
    TimeSliceGraph *edge = nil;
    edge = (TimeSliceGraph *)[[sourceNode destinations]
        objectForKey: dest];
    if (edge == nil){
      edge = [[TimeSliceGraph alloc] init];
      [edge setName: [NSString stringWithFormat: @"%@#%@",
        source, dest]];

      NSMutableDictionary *timeSliceColors = nil;
      timeSliceColors = [edge timeSliceColors];

      //setting colors for values of the entity type
      NSArray *allValuesOfType;
      allValuesOfType = [self allValuesForEntityType: type];
      NSEnumerator *en3;
      id val;
      en3 = [allValuesOfType objectEnumerator];
      while ((val = [en3 nextObject]) != nil) {
        [timeSliceColors setObject:
          [self colorForValue: val
                ofEntityType: type]
            forKey: val];
      }

      //register the edge by destNode
      [[sourceNode destinations] setObject:edge
                  forKey:dest];
      [edge release];
    }

    //lets aggregated in time
    NSDate *start = [ent startTime];
    NSDate *end = [ent endTime];
    //controlling the time-slice border
    start = [start laterDate: sliceStartTime];
    end = [end earlierDate: sliceEndTime];

    //calculting the duration and getting value
    double duration = [end timeIntervalSinceDate: start];
    double integrated;
    if (duration){
      integrated = duration * 1; //value of 1 for each link
    }else{
      integrated = 1; //TODO: if duration=0, just count links
    }
    
    NSMutableDictionary *timeSliceValues = nil;

    //getting the existing timeSliceValues for this node
    timeSliceValues = [edge timeSliceValues];  

    //the name is the value of the link
    NSString *name = [ent value];

    //getting the current value
    double value = [[timeSliceValues objectForKey: name]
          doubleValue];
    value += integrated;

    //saving in the timeSliceValues dict
    [timeSliceValues setObject: [NSNumber numberWithDouble: value]
            forKey: name];
  }
}

- (void) createGraphBasedOnLinks: (id) instance
      withTree: (TimeSliceTree *) node
{
  PajeEntityType *et = [self entityTypeForEntity: instance];
  NSEnumerator *en;
  en = [[self containedTypesForContainerType: et] objectEnumerator];
  while ((et = [en nextObject]) != nil) {
    if ([self isContainerEntityType:et]) {
      NSEnumerator *en2;
      PajeContainer *sub;
      en2 = [self enumeratorOfContainersTyped: et
                inContainer:instance];
      while ((sub = [en2 nextObject]) != nil) {
        TimeSliceTree *child;
        child = (TimeSliceTree*)[nodeNames objectForKey: [sub name]];
        [self createGraphBasedOnLinks: sub
            withTree: child];
      }
    }else{
      if ([et isKindOfClass: [PajeLinkType class]]){
        PajeLinkType *linkType = (PajeLinkType*)et;
        [self timeSliceOfLinkAt: instance
          withType: linkType
          withNode: node];
      }
    }
  }
}
@end
