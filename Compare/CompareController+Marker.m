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
#include "CompareController.h"

@implementation CompareController (Marker)
- (NSArray*) markerTypesWithContainerType: (PajeEntityType *) contType
                               fromFilter: (id) filter
{
  NSMutableArray *ret = [NSMutableArray array];
  NSEnumerator *en = [[filter containedTypesForContainerType: contType] objectEnumerator];
  id type;
  while ((type = [en nextObject])){
    if ([filter isContainerEntityType: type]){
      [ret addObjectsFromArray: [self markerTypesWithContainerType: type
                                                        fromFilter: filter]];
    }else{
      if ([type isKindOfClass: [PajeEventType class]]){
        [ret addObject: type];
      }
    }
  }
  return ret;
}

- (NSArray*) markerTypes
{
  id filter = [compareFilters objectAtIndex: 0];
  return [self markerTypesWithContainerType: [filter rootEntityType]
                                 fromFilter: filter];
}
@end
