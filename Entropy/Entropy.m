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
    [NSBundle loadGSMarkupNamed: @"Entropy" owner: self];
    [window initializeWithDelegate: self];
  }
  leafContainers = nil;
  bestAggregationContainer = nil;
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

- (NSMutableArray *) childrenOfContainer: (PajeContainer *) cont
{
  NSMutableArray *ret = [NSMutableArray array];

  NSArray *containedTypes = [self containedTypesForContainerType: [cont entityType]];
  NSEnumerator *en = [containedTypes objectEnumerator];
  PajeEntityType *type = nil;
  while ((type = [en nextObject])){
    if ([self isContainerEntityType: type]){
      NSEnumerator *en0 = [self enumeratorOfContainersTyped: type inContainer: cont];
      PajeContainer *sub;
      while ((sub = [en0 nextObject]) != nil) {
        [ret addObject: sub];
      }
    }
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

- (void) multiplyThis: (NSMutableDictionary *) origin
	       byThis: (double) m
{
  NSEnumerator *en = [origin keyEnumerator];
  NSString *key;
  while ((key = [en nextObject])){
    double currentValue = [[origin objectForKey: key] doubleValue];
    currentValue *= m;
    [origin setObject: [NSNumber numberWithDouble: currentValue]
	       forKey: key];
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

- (NSDictionary *) informationLossOfContainer: (PajeContainer*) cont
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSArray *leafConts = [self leafContainersInContainer: cont];
  NSDictionary *vzero = [self spatialIntegrationOfContainer: [self rootInstance]];
  NSDictionary *spatial = [self spatialIntegrationOfContainer: cont];
  NSEnumerator *en = [vzero keyEnumerator];
  id variable;
  while ((variable = [en nextObject])){
    double var_spatial_integrated = [[spatial objectForKey: variable] doubleValue];
    double var_vzero = [[vzero objectForKey: variable] doubleValue];
    double ratio = var_spatial_integrated / var_vzero;
    double information_loss = ratio * log2 ([leafConts count]);
    [ret setObject: [NSNumber numberWithDouble: information_loss] forKey: variable];
  }
  return ret;
}

- (NSDictionary *) divergenceOfContainer: (PajeContainer*) cont
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSDictionary *loss = [self informationLossOfContainer: cont];
  NSDictionary *gain = [self entropyGainOfContainer: cont];
  [self addThis: loss toThis: ret];
  [self subtractThis: gain fromThis: ret];
  return ret;
}

- (NSDictionary *) ricOfContainer: (PajeContainer*) cont
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSDictionary *gain = [self entropyGainOfContainer: cont];
  NSDictionary *loss = [self informationLossOfContainer: cont];
  [self addThis: gain toThis: ret];
  [self addThis: gain toThis: ret];
  [self subtractThis: loss fromThis: ret];
  return ret;
}


- (NSDictionary *) pRicOfContainer: (PajeContainer*) cont
                             withP: (double) pval
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSMutableDictionary *gain = [NSMutableDictionary dictionaryWithDictionary: [self entropyGainOfContainer: cont]];
  NSMutableDictionary *div = [NSMutableDictionary dictionaryWithDictionary: [self divergenceOfContainer: cont]];
  [self multiplyThis: gain byThis: 2*pval];
  [self multiplyThis: div byThis: 2*(1-pval)];
  [self addThis: gain toThis: ret];
  [self subtractThis: div fromThis: ret];
  return ret;
}

- (BOOL) entropyLetDisaggregateContainer: (PajeContainer*) cont
{
  return ![self entropyLetShowContainer: cont];
}

- (BOOL) entropyLetShowContainer: (PajeContainer*) cont
{
  if ([bestAggregationContainer containsObject: cont]){
    return YES;
  }else{
    return NO;
  }
}

- (NSArray *) maxPRicOfContainer: (PajeContainer*) cont
                           withP: (double) pval
{
  double ricOfContainer = 0;
  NSDictionary *dict = [self pRicOfContainer: cont withP: pval];
  NSArray *array = [[dict keyEnumerator] allObjects];
  if ([array count]){
    ricOfContainer = [[dict objectForKey: [array objectAtIndex: 0]] doubleValue];
  }
  NSArray *bestAggregationOfContainer = [NSArray arrayWithObject: cont];
  double ricOfChildren = 0;
  NSMutableArray *bestAggregationOfChildren = [NSMutableArray new];

  NSArray *childConts = [self childrenOfContainer: cont];
  if (![childConts count]) {
    return [NSArray arrayWithObjects:
                      [NSNumber numberWithDouble: ricOfContainer],
                    bestAggregationOfContainer,
                    nil];
  }

  NSEnumerator *en = [childConts objectEnumerator];
  PajeContainer *child;
  while ((child = [en nextObject])){
    NSArray *array = [self maxPRicOfContainer: child withP: p];
    ricOfChildren += [[array objectAtIndex: 0] doubleValue];
    [bestAggregationOfChildren addObjectsFromArray: [array objectAtIndex: 1]];
  }

  NSArray *ret;
  if (ricOfChildren > ricOfContainer){
    ret = [NSArray arrayWithObjects:
                     [NSNumber numberWithDouble: ricOfChildren],
                   bestAggregationOfChildren,
                   nil];
  }else{
    ret = [NSArray arrayWithObjects:
                     [NSNumber numberWithDouble: ricOfContainer],
                   bestAggregationOfContainer,
                   nil];
  }
  return ret;
}


- (void) timeSelectionChanged
{
  [super timeSelectionChanged];
}

- (void) hierarchyChanged
{
  if (leafContainers){
    [leafContainers release];
    leafContainers = nil;
  }
  [self recalculateBestAggregation];
  [super hierarchyChanged];
}

- (void) recalculateBestAggregation
{
  [bestAggregationContainer release];

  NSArray *array = [self maxPRicOfContainer: [self rootInstance] withP: p];
  bestAggregationContainer = [array objectAtIndex: 1];
  [bestAggregationContainer retain];
}

- (void) pChanged
{
  [self recalculateBestAggregation];
}
@end
