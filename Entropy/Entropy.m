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
#include "Entropy.h"

@implementation Entropy
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
  }
  leafContainers = nil;
  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (NSMutableArray *) leafContainersInContainer: (PajeContainer *) cont
{
  NSMutableArray *ret = [NSMutableArray array];

  NSArray *containedTypes = [self containedTypesForContainerType: [cont entityType]];
  NSEnumerator *en = [containedTypes objectEnumerator];
  PajeEntityType *type = nil;
  BOOL leaf = YES;
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      NSEnumerator *en0 = [self enumeratorOfContainersTyped: type inContainer: cont];
      PajeContainer *sub;
      while ((sub = [en0 nextObject]) != nil) {
        [ret addObjectsFromArray: [self leafContainersInContainer: sub]];
      }
      leaf = NO;
    }
  }

  if (leaf){
    [ret addObject: cont];
  }
  return ret;
}

- (void) addThis: (NSDictionary *) origin
          toThis: (NSMutableDictionary *) destination
{
  NSEnumerator *en = [origin keyEnumerator];
  NSString *key;
  while ((key = [en nextObject])){
    id existing = [destination objectForKey: key];
    if (existing == nil){
      [destination setObject: [origin objectForKey: key]
                      forKey: key];
    }else{
      double currentValue = [existing doubleValue];
      currentValue += [[origin objectForKey: key] doubleValue];
      [destination setObject: [NSNumber numberWithDouble: currentValue]
                      forKey: key];
    }
  }
}

- (void) subtractThis: (NSDictionary *) origin
             fromThis: (NSMutableDictionary *) destination
{
  NSEnumerator *en = [origin keyEnumerator];
  NSString *key;
  while ((key = [en nextObject])){
    id existing = [destination objectForKey: key];
    if (existing == nil){
      [destination setObject: [origin objectForKey: key]
                      forKey: key];
    }else{
      double currentValue = [existing doubleValue];
      currentValue -= [[origin objectForKey: key] doubleValue];
      [destination setObject: [NSNumber numberWithDouble: currentValue]
                      forKey: key];
    }
  }
}

- (NSDictionary*) vzeroOfType: (PajeEntityType*) type
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];

  if (leafContainers == nil){
    leafContainers = [self leafContainersInContainer: [self rootInstance]];
    [leafContainers retain];
  }

  NSEnumerator *en = [leafContainers objectEnumerator];
  PajeContainer *container;

  while ((container = [en nextObject])){
    NSDictionary *dict = [self integrationOfContainer: container];
    [self addThis: dict toThis: ret];
  }
  return ret;
}

- (NSDictionary *) entropyOfContainer: (PajeContainer*) cont
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];

  NSDictionary *vzero = [self spatialIntegrationOfContainer: [self rootInstance]];
  NSDictionary *spatial = [self spatialIntegrationOfContainer: cont];
  NSEnumerator *en = [vzero keyEnumerator];
  id variable;
  while ((variable = [en nextObject])){
    double var_spatial_integrated = [[spatial objectForKey: variable] doubleValue];
    double var_vzero = [[vzero objectForKey: variable] doubleValue];
    double ratio = var_spatial_integrated / var_vzero;
    double entropy;
    if (ratio != 0){
      entropy = -ratio * log2 (ratio);
    }else{
      entropy = 0;
    }
    [ret setObject: [NSNumber numberWithDouble: entropy] forKey: variable];
  }
  return ret;
}

- (NSDictionary *) entropyGainOfContainer: (PajeContainer *) cont
{
  NSArray *leafConts = [self leafContainersInContainer: cont];
  NSEnumerator *en = [leafConts objectEnumerator];
  PajeContainer *leaf;
  NSMutableDictionary *accum = [NSMutableDictionary dictionary];
  while ((leaf = [en nextObject])){
    NSDictionary *entropy = [self entropyOfContainer: leaf];
    [self addThis: entropy toThis: accum];
  }

  NSDictionary *contEntropy = [self entropyOfContainer: cont];
  [self subtractThis: contEntropy fromThis: accum];
  return accum;
}

- (void) test: (PajeContainer*) cont
{
  {
    NSDictionary *dict = [self entropyGainOfContainer: cont];
    id variable;
    NSEnumerator *en = [dict keyEnumerator];
    while ((variable = [en nextObject])){
      NSLog (@"node = %@, entropy_gain_%@ = %@", [cont name], variable, [dict objectForKey: variable]);
    }
  }

  NSArray *containedTypes = [self containedTypesForContainerType: [cont entityType]];
  NSEnumerator *en = [containedTypes objectEnumerator];
  PajeEntityType *type = nil;
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      NSEnumerator *en0 = [self enumeratorOfContainersTyped: type inContainer: cont];
      PajeContainer *sub;
      while ((sub = [en0 nextObject]) != nil) {
        [self test: sub];
      }
    }
  }
}

- (void) timeSelectionChanged
{
  [self test: [self rootInstance]];
//  NSLog (@"%@", [self entropyOfContainer: [self rootInstance]]);
  [super timeSelectionChanged];
}
@end
