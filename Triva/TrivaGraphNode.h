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
#ifndef __TrivaGraphNode_h
#define __TrivaGraphNode_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <Tree.h>

@class TrivaFilter;
@class TrivaNodeGraph;

@interface TrivaComposition : NSObject
+ (id) compositionWithConfiguration: (NSDictionary*) conf
                          forObject: (TrivaNodeGraph*)obj
                         withValues: (NSDictionary*) timeSliceValues
                        andProvider: (TrivaFilter*) prov;
- (id) initWithConfiguration: (NSDictionary*) conf
                   forObject: (TrivaNodeGraph*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov;
@end

@interface TrivaSeparation : TrivaComposition
{
	NSRect bb; //the bounding box
	NSMutableDictionary *values; //(NSString*)name = (NSNumber)value
			      //the sum of the values must be equal = 1
	double overflow; //(sum_of_the_values - 1)
			 //can be used to check if the sum is > 1
	id filter;
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

@interface TrivaGraphNode : Tree
{
	NSString *type; //node type (entitytype from paje)
	//NSString *name (declared in super class); node name (unique id)
	NSRect bb; //the bounding box of the node (indicates size and position)
	NSRect screenbb; //the bounding box of the screen
	NSMutableArray *compositions; //array of TrivaComposition objects
	
	BOOL drawable; //is it ready to draw?
}
- (void) setType: (NSString *) n;
- (NSString *) type;
- (void) setBoundingBox: (NSRect) b;
- (NSRect) bb;
- (NSRect) screenbb;
- (void) setDrawable: (BOOL)v;
- (BOOL) drawable;
- (void) refresh;
- (BOOL) draw;
- (void) addComposition: (TrivaComposition*)comp;
- (void) removeCompositions;
- (void) convertFrom: (NSRect) this to: (NSRect) screen;
@end


#include "TrivaFilter.h"
#endif
