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
#include "TrivaGraph.h"
#include <float.h>

#define BIGFLOAT FLT_MAX

@implementation TrivaGraph
+ (TrivaGraph*) nodeWithName: (NSString*)n
                      depth: (int)d
                     parent: (TrivaTree*)p
                   expanded: (BOOL)e
                  container: (PajeContainer*)c
                     filter: (TrivaFilter*)f
{
  return [[[self alloc] initWithName: n
              depth:d
             parent:p
           expanded:e
          container:c
             filter:f] autorelease];
}


- (id) initWithName: (NSString*)n
              depth: (int)d
             parent: (TrivaTree*)p
           expanded: (BOOL)e
          container: (PajeContainer*)c
             filter: (TrivaFilter*)f
{
  self = [super initWithName:n depth:d parent:p expanded:e container:c filter:f];
  if (self != nil){
    compositions = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void) dealloc
{
  [compositions release];
  [super dealloc];
}

- (void) timeSelectionChanged
{
  [super timeSelectionChanged];
  //NSLog (@"%@ %@ layout myself with %@", name, values, [filter graphConfigurationForContainerType: [container entityType]]);

//- (void) layoutWith:(NSDictionary*)conf
//             values:(NSDictionary*)currentValues
//          minValues:(NSDictionary *)minValues
//          maxValues:(NSDictionary*)maxValues
//             colors:(NSDictionary*)colors
  NSDictionary *minValues = [filter minValuesForContainerType: [container entityType]];
  NSDictionary *maxValues = [filter maxValuesForContainerType: [container entityType]];

  //layout myself with update my graph values
  NSDictionary *conf = [filter graphConfigurationForContainerType: [container entityType]];
  if (conf){
    //layout myself
    NSString *sizeconf = [conf objectForKey: @"size"];
    double screensize;
    if ([self expressionHasVariables: sizeconf]){
      double min = [self evaluateWithValues: minValues withExpr: sizeconf];
      double max = [self evaluateWithValues: maxValues withExpr: sizeconf];
      double dif = max- min;
      double val = [self evaluateWithValues: values withExpr: sizeconf];
      if (dif != 0) {
        screensize = MIN_SIZE + ((val - min)/dif)*(MAX_SIZE-MIN_SIZE);
      }else{
        screensize = MIN_SIZE + ((val - min)/min)*(MAX_SIZE-MIN_SIZE);
      }
      size = val;
    }else{
      screensize = [sizeconf doubleValue];
    }
    bb.size.width = screensize;
    bb.size.height = screensize;
  }

  //layout my children
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child timeSelectionChanged];
  }
}

- (void) drawLayout
{
  [[NSColor blackColor] set];
  [NSBezierPath strokeRect: bb];
}

/*
 * Search method
 */
- (TrivaGraph *) searchWith: (NSPoint) point
    limitToDepth: (int) d
{
  return nil;
  double x = point.x;
  double y = point.y;
  TrivaGraph *ret = nil;
  if (x >= bb.origin.x &&
      x <= bb.origin.x+bb.size.width &&
      y >= bb.origin.y &&
      y <= bb.origin.y+bb.size.height){
    if ([self depth] == d){
      // recurse to aggregated children 
    }else{
      // recurse to ordinary children 
      unsigned int i;
      for (i = 0; i < [children count]; i++){
        TrivaGraph *child;
        child = [children objectAtIndex: i];
        ret = [child searchWith: point
                   limitToDepth: d];
        if (ret != nil){
          break;
        }
      }
    }
  }
  return ret;
}

/* 
 * expressions
 */
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

- (double) evaluateWithValues: (NSDictionary *) vals
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
      NSString *val = [vals objectForKey: var];
      if (val){
        expr_values[i] = [val doubleValue];
      }else{
        static BOOL appeared = NO;
        if (!appeared){
          NSLog (@"%s:%d Expression (%@) has variables that are "
            "not present in the aggregated tree (%@). Considering "
            "that their values is zero. This message appears only once.",
            __FUNCTION__, __LINE__, expr, vals);
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

@end
