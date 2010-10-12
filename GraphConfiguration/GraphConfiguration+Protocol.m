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
/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GraphConfiguration.h"

@implementation GraphConfiguration (Protocol)
// implementation the TrivaFilter "protocol" 
- (NSEnumerator*) enumeratorOfNodes
{
  return [nodes objectEnumerator];
}

- (NSEnumerator*) enumeratorOfEdges
{
  return [edges objectEnumerator];
}

- (NSRect) sizeForGraph
{
  if (userPositionEnabled){
    return graphSize;
  }else if (graphvizEnabled){
    NSRect ret;
    ret.origin.x = ret.origin.y = 0;
    if (graph){
      ret.size.width = GD_bb(graph).UR.x;
      ret.size.height = GD_bb(graph).UR.y;
    }else{
      ret.size.width = 0;
      ret.size.height = 0;
    }
    return ret;
  }else{
    return NSZeroRect;
  }
}

- (TrivaGraphNode*) findNodeByName: (NSString *)name
{
  TrivaGraphNode *ret;
  NSEnumerator *en = [nodes objectEnumerator];
  while ((ret = [en nextObject])){
    if ([name isEqualToString: [ret name]]){
      return ret;
    }
  }
  return nil;
}

- (BOOL) expressionHasVariables: (NSString*) expr
{
  BOOL ret;
  char **expr_names;
  int count;
  void *f = evaluator_create ((char*)[expr cString]);
  evaluator_get_variables (f, &expr_names, &count);
  if (count == 0){
    ret = NO;
  }else{
    ret = YES;
  }
  evaluator_destroy (f);
  return ret;
}

- (double) evaluateWithValues: (NSDictionary *) values
    withExpr: (NSString *) expr
{
  char **expr_names;
  double *expr_values, ret;
  int count, i;
  void *f = evaluator_create ((char*)[expr cString]);
  evaluator_get_variables (f, &expr_names, &count);
  if (count == 0){
    //no variables detected, return doubleValue
    return [expr doubleValue];
  }else{
    //ok, we have some variables to be defined
    expr_values = (double*)malloc (count * sizeof(double));
    for (i = 0; i < count; i++){
      NSString *var = [NSString stringWithFormat: @"%s", expr_names[i]];  
      NSString *val = [values objectForKey: var];
      if (val){
        expr_values[i] = [val doubleValue];
      }else{
        static BOOL appeared = NO;
        if (!appeared){
          NSLog (@"%s:%d Expression (%@) has variables that are "
            "not present in the aggregated tree (%@). Considering "
            "that their values is zero. This message appears only once.",
            __FUNCTION__, __LINE__, expr, values);
          appeared = YES;
        }
        expr_values[i] = 0;
 
      }
    }
    ret = evaluator_evaluate (f, count, expr_names, expr_values);
    evaluator_destroy (f);
    free(expr_values);
  }
  return ret; 
}

- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation
{
  if (![[c colorSpaceName] isEqualToString:
      @"NSCalibratedRGBColorSpace"]){
    NSLog (@"%s:%d Color provided is not part of the "
        "RGB color space.", __FUNCTION__, __LINE__);
    return nil;
  }
  float h, s, b, a;
  [c getHue: &h saturation: &s brightness: &b alpha: &a];
  NSColor *ret = [NSColor colorWithCalibratedHue: h
    saturation: saturation
    brightness: b
    alpha: a];
  return ret;
}

- (void) graphComponentScalingChanged
{
  [self timeSelectionChanged];
}

- (void) __defineMax: (double*)max
            andMin: (double*)min
         withScale: (TrivaScale) scale
      fromVariable: (NSString*)var
          ofObject: (NSString*) objName
          withType: (NSString*) objType
{
  PajeEntityType *valtype = [self entityTypeWithName: var];
  if (scale == Global){
    *min = [self minValueForEntityType: valtype];
    *max = [self maxValueForEntityType: valtype];
  }else if (scale == Local){
    //if local scale, *min and *max from this container
    //  container is found based on the name of the obj
    PajeEntityType *type = [self entityTypeWithName: objType]; 
    PajeContainer *cont = [self containerWithName: objName type: type];
    *min = [self minValueForEntityType: valtype inContainer: cont];
    *max = [self maxValueForEntityType: valtype inContainer: cont];
  }else if (scale == Convergence || scale == Arnaud){
    PajeEntityType *type = [self entityTypeWithName: objType];
    PajeContainer *cont = [self containerWithName: objName type: type];

    *max = 0;
    *min = FLT_MAX;
    NSEnumerator *en = [self enumeratorOfEntitiesTyped: valtype
                                           inContainer: cont
                                              fromTime:[self selectionStartTime]
                                                toTime: [self endTime]
                                           minDuration: 0];
    id ent;
    while ((ent = [en nextObject])){
      double val = [[ent value] doubleValue];
      if (val > *max) *max = val;
      if (val < *min) *min = val;
    }
  }
}

- (double) maxOfVariable: (NSString *) variable
               withScale: (TrivaScale) scale
                ofObject: (NSString *) entityName
                withType: (NSString *) entityType
{
  double max = -FLT_MAX;

  //check if it is already on cache
  NSNumber *number = [maxCache objectForKey: variable];
  if (number) return [number doubleValue];

  //get the array of objects from entities
  NSEnumerator *en;
  id entity;
  en = [[entities objectForKey: entityType] objectEnumerator];
  while ((entity = [en nextObject])){
    TimeSliceTree *tst;
    tst = (TimeSliceTree *)[[self timeSliceTree] searchChildByName:
                                                            [entity name]];
    double val = [self evaluateWithValues: [tst timeSliceValues]
                                 withExpr: variable];
    if (val > max) max = val;
  }
  //save the value on the maxCache
  [maxCache setObject: [NSNumber numberWithDouble: max] forKey: variable];
  return max;
}

- (double) minOfVariable: (NSString *) variable
               withScale: (TrivaScale) scale
                ofObject: (NSString *) entityName
                withType: (NSString *) entityType
{
  double min = FLT_MAX;

  //check if it is already on cache
  NSNumber *number = [minCache objectForKey: variable];
  if (number) return [number doubleValue];

  //get the array of objects from entities
  NSEnumerator *en;
  id entity;
  en = [[entities objectForKey: entityType] objectEnumerator];
  while ((entity = [en nextObject])){
    TimeSliceTree *tst;
    tst = (TimeSliceTree *)[[self timeSliceTree] searchChildByName:
                                                            [entity name]];
    double val = [self evaluateWithValues: [tst timeSliceValues]
                                 withExpr: variable];
    if (val < min) min = val;
  }
  //save the value on the maxCache
  [minCache setObject: [NSNumber numberWithDouble: min] forKey: variable];
  return min;
}
@end
