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
#include "EntityDot.h"

@implementation EntityDot
- (id)initWithController:(PajeTraceController *)c
{
  return [super initWithController: c];
}

- (void) dumpEntityType: (PajeContainer *) container
{

  NSEnumerator *en = [[self containedTypesForContainerType: [self entityTypeForEntity: container]] objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject]) != nil) {
    if ([self isContainerEntityType: type]) {
      NSEnumerator *en = [self enumeratorOfContainersTyped: type inContainer: container];
      PajeContainer *subcontainer;
      while ((subcontainer = [en nextObject]) != nil) {
        printf ("  \"%s\" [ shape=box ];\n", [[subcontainer name] UTF8String]);
        printf ("  \"%s\" -- \"%s\";\n", [[container name] UTF8String], [[subcontainer name] UTF8String]);
        [self dumpEntityType: subcontainer];
      }
    } else if ([type isKindOfClass: [PajeLinkType class]]){
      NSDate *st = [NSDate dateWithTimeIntervalSinceReferenceDate: -1];
      NSDate *et = [self endTime];
      NSEnumerator *en = [self enumeratorOfEntitiesTyped: type
                                             inContainer: container
                                                fromTime: st
                                                  toTime: et
                                             minDuration: 0.0];
      PajeEntity *entity;
      while ((entity = [en nextObject])){
        printf ("  \"%s\" -- \"%s\" [ color = \"red\" ];\n",
                [[[entity sourceContainer] name] UTF8String],
                [[[entity destContainer] name] UTF8String]);
      }
    }
  }
}

- (void) timeSelectionChanged
{
  printf ("graph {\n");
  printf ("  graph [ranksep=3, root=\"%s\"]\n", [[[self rootInstance] name] UTF8String]);
  [self dumpEntityType: [self rootInstance]];
  printf ("}\n");
  [NSApp terminate: self];
}
@end
