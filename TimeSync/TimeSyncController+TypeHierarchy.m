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
#include "TimeSyncController.h"

@interface TimeSyncController (TypeHierarchyHidden)
- (NSDictionary *) typeHierarchy: (id) filter ofType: (PajeEntityType*) type;
- (NSDictionary *) typeHierarchy: (id) filter;
@end


@implementation TimeSyncController (TypeHierarchyHidden)
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
@end

@implementation TimeSyncController (TypeHierarchy)
- (BOOL) checkTypeHierarchies: (NSArray*)filters
{
  NSMutableArray *typeHierarchies = [NSMutableArray array];
  NSEnumerator *en0 = [filters objectEnumerator];
  id filter = nil;
  while ((filter = [en0 nextObject])){
    [typeHierarchies addObject: [self typeHierarchy: filter]];
  }

  NSEnumerator *en1 = [typeHierarchies objectEnumerator];
  NSDictionary *t1 = [en1 nextObject];
  NSDictionary *t2 = nil;
  while ((t2 = [en1 nextObject])){
    if (![t1 isEqualToDictionary: t2]){
      return NO;
    }
    t1 = t2;
  }
  return YES;
}
@end
