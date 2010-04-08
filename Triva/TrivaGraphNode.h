#ifndef __TrivaGraphNode_h
#define __TrivaGraphNode_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>

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
- (void) draw;
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

@interface TrivaGraphNode : NSObject
{
	NSString *type; //node type (entitytype from paje)
	NSString *name; //node name (unique indentification)
	NSRect bb; //the bounding box of the node (indicates size and position)
	NSRect screenbb; //the bounding box of the screen
	NSMutableArray *compositions; //array of TrivaComposition objects
	
	BOOL drawable; //is it ready to draw?
}
- (void) setType: (NSString *) n;
- (NSString *) type;
- (void) setName: (NSString *) n;
- (NSString *) name;
- (void) setBoundingBox: (NSRect) bb;
- (NSRect) bb;
- (NSRect) screenbb;
- (void) setDrawable: (BOOL)v;
- (BOOL) drawable;
- (void) refresh;
- (void) draw;
- (void) addComposition: (TrivaComposition*)comp;
- (void) removeCompositions;
- (void) convertFrom: (NSRect) this to: (NSRect) screen;
@end


#include "TrivaFilter.h"
#endif
