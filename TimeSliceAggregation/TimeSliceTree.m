#include "TimeSliceTree.h"

@implementation TimeSliceTree
- (id) init
{
	self = [super init];
	timeSliceValues = nil;
	aggregatedValues = nil;
	return self;
}

- (void) dealloc
{
	[pajeEntities release];
	[timeSliceValues release];
	[aggregatedValues release];
	[super dealloc];
}

- (void) setPajeEntities: (NSDictionary *) values
{
	if (pajeEntities){
		[pajeEntities release];
	}
	pajeEntities= [NSMutableDictionary dictionaryWithDictionary: values];
	[pajeEntities retain];
}

- (NSDictionary *) pajeEntities
{
	return pajeEntities;
}

- (void) setTimeSliceValues: (NSDictionary *) values
{
	if (timeSliceValues){
		[timeSliceValues release];
	}
	timeSliceValues= [NSMutableDictionary dictionaryWithDictionary: values];
	[timeSliceValues retain];
}
- (NSDictionary *) timeSliceValues
{
	return timeSliceValues;
}

- (void) setAggregatedValues: (NSDictionary *) aggValues
{
	if (aggregatedValues){
		[aggregatedValues release];
	}
	aggregatedValues = [NSMutableDictionary 
				dictionaryWithDictionary: aggValues];
	[aggregatedValues retain];
}

- (NSDictionary *) aggregatedValues
{
	return aggregatedValues;
}

- (float) finalValue
{
	return finalValue;
}

- (void) setFinalValue: (float) f
{
	finalValue = f;
}

- (NSComparisonResult) compareValue: (TimeSliceTree *) other
{
        if (finalValue < [other finalValue]){
                return NSOrderedAscending;
        }else if (finalValue > [other finalValue]){
                return NSOrderedDescending;
        }else{
                return NSOrderedSame;
        }
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"%@-%@", name, aggregatedValues];
}

- (void) testTree
{
	int i;
	if ([children count] != 0){
		for (i = 0; i < [children count]; i++){
			[[children objectAtIndex: i] testTree];
		}
	}
	NSLog (@"%@ - %@ - %.2f", name, pajeEntities, finalValue);
}

- (void) doAggregation
{
	int i;
	if ([children count] != 0){
		// bottom-up
		for (i = 0; i < [children count]; i++){
			[[children objectAtIndex: i] doAggregation];
		}
	}else{
		// stop recursion
		[self setAggregatedValues: [self timeSliceValues]];
		return;
	}
	// do the magic
	NSMutableDictionary *agg;
	agg = [NSMutableDictionary dictionaryWithDictionary:
		[[children objectAtIndex: 0] aggregatedValues]];
	for (i = 1; i < [children count]; i++){
		TimeSliceTree *child = [children objectAtIndex: i];
		NSDictionary *childagg = [child aggregatedValues];
		NSEnumerator *keys = [childagg keyEnumerator];
		id key;
		while ((key = [keys nextObject])){
			float value = [[childagg objectForKey: key] floatValue];
			float aggValue = [[agg objectForKey: key] floatValue];
			aggValue += value; //only addition operation for agg
			[agg setObject: [NSString stringWithFormat: @"%f",
						aggValue] forKey: key];
		}
	}
	[self setAggregatedValues: agg];
	[self setPajeEntities: [[children objectAtIndex: 0] pajeEntities]];
}

- (float) doFinalValueWith: (NSSet *) set
{
	int i;
	float value = 0;
	if ([children count] != 0){
		// bottom-up
		for (i = 0; i < [children count]; i++){
			value += [[children objectAtIndex: i] doFinalValueWith: set];
		}
	}else{
		// stop recursion
		id key;
		NSEnumerator *keys = [aggregatedValues keyEnumerator];
		while ((key = [keys nextObject])){
			if ([set count] != 0){
				if ([set containsObject: key]){
					value += [[aggregatedValues objectForKey: key] floatValue];
				}
			}else{
				value += [[aggregatedValues objectForKey: key] floatValue];
			}
		}
	}
	[self setFinalValue: value];
	return finalValue;

}
@end
