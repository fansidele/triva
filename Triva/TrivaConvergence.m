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
#include "TrivaConvergence.h"

@implementation TrivaConvergence
- (void) defineMax: (double*)ma andMin: (double*)mi fromVariable: (NSString*)var
    ofObject: (NSString*)n withType: (NSString*)type
{
  //define max and min taking into account that this is a convergence composition
  NSDate *start = [filter selectionStartTime]; //from the beggining of the time window
  NSDate *end = [filter endTime]; //to the end

  //prepare
  PajeEntityType *varType = [filter entityTypeWithName: var];
  PajeEntityType *containerType = [filter entityTypeWithName: type];
  PajeContainer *container = [filter containerWithName: n type: containerType];
  *ma = 0;
  *mi = FLT_MAX;
  //do it
  NSEnumerator *en = [filter enumeratorOfEntitiesTyped: varType
                                                 inContainer: container
                                                    fromTime: start
                                                      toTime: end
                                                 minDuration: 0];
  id ent;
  while ((ent = [en nextObject])){
    double val = [[ent value] doubleValue];
    if (val > *ma) *ma = val;
    if (val < *mi) *mi = val;
  }
}

- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  self = [super initWithFilter: prov andConfiguration: conf
                      andSpace: YES andName: n andObject: obj];
  return self;
}

- (BOOL) redefineLayoutWithValues: (NSDictionary*) timeSliceValues
{
  //get values
  NSEnumerator *en2 = [[configuration objectForKey: @"values"]objectEnumerator];
  id var;
  while ((var = [en2 nextObject])){
    double val = [filter evaluateWithValues: timeSliceValues withExpr: var];
    double mi, ma;
    [self defineMax: &ma
                         andMin: &mi
                   fromVariable: var
                       ofObject: [node name]
                       withType: [(TrivaGraphNode*)node type]];
    [self setGradientType: var withValue: val withMax: ma withMin: mi];
  }
  if ([values count] == 0){
    needSpace = NO;
  }else{
    needSpace = YES;
  }
  return NO;
}
@end
