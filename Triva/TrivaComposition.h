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
#ifndef __TrivaComposition_h_
#define __TrivaComposition_h_
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <Triva/Tree.h>
#include <Triva/TimeSliceTree.h>
#include <Triva/TrivaFilter.h>
#include <Triva/TrivaGraphNode.h>

@class TrivaGraphNode;
@class TrivaFilter;

@interface TrivaComposition : NSObject
{
  BOOL needSpace;
}
+ (id) compositionWithConfiguration: (NSDictionary*) conf
                          forObject: (TrivaGraphNode*)obj
                         withValues: (NSDictionary*) timeSliceValues
                        andProvider: (TrivaFilter*) prov;
- (id) initWithConfiguration: (NSDictionary*) conf
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov;
- (BOOL) needSpace;
@end

@interface TrivaSeparation : TrivaComposition
{
  NSRect bb; //the bounding box
  NSMutableDictionary *values; //(NSString*)name = (NSNumber)value
            //the sum of the values must be equal = 1
  double overflow; //(sum_of_the_values - 1)
       //can be used to check if the sum is > 1
  id filter;
  TrivaGraphNode *node;
}
- (id) initWithFilter: (id) f;
- (void) setFilter: (id) f;
- (NSDictionary*) values;
- (double) overflow;
- (void) refreshWithinRect: (NSRect) rect;
- (BOOL) draw;
- (NSRect) bb;
@end

@interface TrivaGradient : TrivaSeparation
{
  NSMutableDictionary *min;
  NSMutableDictionary *max;
}
- (void) setGradientType: (NSString *) type withValue: (double) val
    withMax: (double) max withMin: (double) min;
- (NSDictionary *) min;
- (NSDictionary *) max;
@end

@interface TrivaBar : TrivaGradient
@end

@interface TrivaConvergence : TrivaGradient
- (void) defineMax: (double*)ma andMin: (double*)mi fromVariable: (NSString*)var
                ofObject: (NSString*)name withType: (NSString*)type;
@end

@interface TrivaColor : TrivaSeparation
@end

@interface TrivaSwarm : TrivaComposition
{
  NSRect bb; //the bounding box
  NSMutableArray *objects; //array of strings with the existing objects
  NSMutableDictionary *objectsColors; //dict of string->colors
  TrivaGraphNode *node;
}
@end

@interface TrivaPlot : TrivaComposition
{
  NSRect bb;
  TrivaGraphNode *node;
  NSArray *objects;
  TrivaFilter *provider;

  double tmin, tmax;
  double vmin, vmax;

  double sliceSize;
  double valueSize;
}
@end

#endif
