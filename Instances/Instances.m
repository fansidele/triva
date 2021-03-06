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
#include "Instances.h"

@implementation Instances
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
  }
  return self;
}

- (void)printInstance:(id)instance level:(int)level
{

  NSLog(@"i%*.*s%@", level, level, "", [self descriptionForEntity:instance]);
  PajeEntityType *et;
  NSEnumerator *en;
  en = [[self containedTypesForContainerType:[self entityTypeForEntity:instance]] objectEnumerator];
  while ((et = [en nextObject]) != nil) {
    NSLog(@"t%*.*s%@", level+1, level+1, "", [self descriptionForEntityType:et]);
    if ([self isContainerEntityType:et]) {
      NSEnumerator *en2;
      PajeContainer *sub;
      en2 = [self enumeratorOfContainersTyped:et inContainer:instance];
      while ((sub = [en2 nextObject]) != nil) {
        [self printInstance:sub level:level+2];
      }
    } else {
      NSEnumerator *en3;
      PajeEntity *ent;
      NSDate *startt = [NSDate dateWithTimeIntervalSinceReferenceDate: -1];
      NSDate *endt = [self endTime];
      en3 = [self enumeratorOfEntitiesTyped:et
                                inContainer:instance
                                   fromTime:startt
                                     toTime:endt
                                minDuration:0];
      while ((ent = [en3 nextObject]) != nil) {
        if ([[self entityTypeForEntity: ent] isKindOfClass: [PajeLinkType class]]){
          NSDate *startTime = [ent startTime];
          NSDate *endTime = [ent endTime];
          NSLog(@"e%*.*s%@ [%@ in start=%@ end=%@] duration=%f source=%@ dest=%@ extraFields=%@", level+2, level+2, "",
                [ent valueOfFieldNamed:@"Value"],
                [ent entityType],
                [ent startTime],
                [ent endTime],
                [endTime timeIntervalSinceDate: startTime],
                [[ent sourceContainer] name],
                [[ent destContainer] name],
                [ent extraFields]);
        }else{
          NSLog(@"e%*.*s%@ %@ %@", level+2, level+2, "", [self descriptionForEntity:ent], [[ent container] name], [ent extraFields]);
        }
      }
    }
  }
}

- (void) dumpTraceInTextualFormat
{
  [self printInstance:[self rootInstance] level:0];
}

- (void)hierarchyChanged
{
  [self dumpTraceInTextualFormat];
  exit(0);
}

@end
