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

@implementation CompareController (TypeHierarchy)
- (NSDictionary *) typeHierarchy: (id) filter ofType: (PajeEntityType*) type
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSEnumerator *en = [[filter containedTypesForContainerType: type]
                        objectEnumerator];
  id et;
  while ((et = [en nextObject]) != nil) {
    if ([filter isContainerEntityType: et]) {
      [ret setObject: [self typeHierarchy: filter ofType: et] forKey: et];
    }else{
      [ret setObject: et forKey: et];
    }
  }
  return ret;
}

- (NSDictionary *) typeHierarchy: (id) filter
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  PajeEntityType *rootType = [[filter rootInstance] entityType];
  [ret setObject: [self typeHierarchy: filter ofType: rootType] forKey: rootType];
  return ret;
}

- (BOOL) checkTypeHierarchies: (NSArray*)typeHierarchies
{
  NSDictionary *t1 = [typeHierarchies objectAtIndex: 0];
  NSDictionary *t2 = [typeHierarchies objectAtIndex: 1];

  return [t1 isEqualToDictionary: t2];
}
@end
