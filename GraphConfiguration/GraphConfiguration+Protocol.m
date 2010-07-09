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

#define MAX_SIZE   60

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

- (void) defineMax: (double*)max andMin: (double*)min withScale: (TrivaScale) scale
    fromVariable: (NSString*)var
    ofObject: (NSString*) objName withType: (NSString*) objType
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
  }else if (scale == Convergence){
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

- (double) evaluateWithValues: (NSDictionary *) values
    withExpr: (NSString *) expr
{
  if (!expr) return -2;

  NSMutableString *size_def = [NSMutableString stringWithString: expr];
  int number = 0;
  if (values){
    NSEnumerator *en2 = [values keyEnumerator];
    NSString *val;
    while ((val = [en2 nextObject])){
      NSString *repl = [NSString stringWithFormat: @"%@",
        [values objectForKey: val]];
      number += [size_def replaceOccurrencesOfString: val
        withString: repl
        options: NSLiteralSearch
        range: NSMakeRange(0, [size_def length])];
    }
  }

  //math eval to define size
  char **names;
  int count;
  void *f = evaluator_create ((char*)[size_def cString]);
  evaluator_get_variables (f, &names, &count);
  if (count != 0){
//    NSLog (@"%s:%d Expression (%@) has variables that are "
//      "not present in the aggregated tree. Considering "
//      "that their values is zero.",
//      __FUNCTION__, __LINE__, size_def);
    int i;
    double *zeros = (double*)malloc(count*sizeof(double));
    for (i = 0; i < count; i++){
      zeros[i] = 0;
    }
    double ret = evaluator_evaluate (f, count, names, zeros);
    evaluator_destroy (f);
    free (zeros);
    return ret;
  }else{
    if (!number){
      evaluator_destroy (f);
      return -1; /* to indicate that is a numeric value */
    }
    double ret = evaluator_evaluate (f, 0, NULL, NULL);
    evaluator_destroy (f);
    return ret;
  }
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
@end
