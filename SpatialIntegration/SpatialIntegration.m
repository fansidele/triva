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
#include "SpatialIntegration.h"

@implementation SpatialIntegration
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
  }
  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (NSDictionary *) integrationOfContainer: (PajeContainer *) cont
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSEnumerator *en = [[self containedTypesForContainerType: [cont entityType]] objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject])){
    if (![self isContainerEntityType: type]){
      [ret addEntriesFromDictionary:
            [self timeIntegrationOfType: type inContainer: cont]];
    }
  }
  return ret;
}

- (void) mergeDictionary: (NSMutableDictionary *) mergeTo
          withDictionary: (NSDictionary *) mergeFrom
{
  NSEnumerator *en = [mergeFrom keyEnumerator];
  NSString *key;
  while ((key = [en nextObject])){
    id existing = [mergeTo objectForKey: key];
    if (existing == nil){
      [mergeTo setObject: [mergeFrom objectForKey: key]
                  forKey: key];
    }else{
      //additive aggregation TODO: should be customizable?
      double currentValue = [existing doubleValue];
      currentValue += [[mergeFrom objectForKey: key] doubleValue];
      [mergeTo setObject: [NSNumber numberWithDouble: currentValue]
                  forKey: key];
    }
  }
}

- (NSDictionary *) spatialIntegrationOfContainer: (PajeContainer *) cont
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];

  //integrate myself-only
  [ret addEntriesFromDictionary: [self integrationOfContainer: cont]];

  //spatial integration
  NSEnumerator *en = [[self containedTypesForContainerType: [cont entityType]] objectEnumerator];
  PajeEntityType *type;
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      NSEnumerator *en0 = [self enumeratorOfContainersTyped:type
                                                inContainer:cont];
      PajeContainer *sub;
      while ((sub = [en0 nextObject]) != nil) {
        [self mergeDictionary: ret
               withDictionary: [self spatialIntegrationOfContainer: sub]];
      }
    }
  }
  //TODO: save on cache
  return ret;
}
@end
