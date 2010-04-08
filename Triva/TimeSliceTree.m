#include "TimeSliceTree.h"
#include <float.h>

@implementation TimeSliceTree
- (id) init
{
	self = [super init];
	timeSliceValues = [[NSMutableDictionary alloc] init];
	maxValues = [[NSMutableDictionary alloc] init];
	minValues = [[NSMutableDictionary alloc] init];
	timeSliceColors = [[NSMutableDictionary alloc] init];
	aggregatedValues = [[NSMutableDictionary alloc] init];
	timeSliceDurations = [[NSMutableDictionary alloc] init];
	return self;
}

- (void) dealloc
{
	[timeSliceValues release];
	[maxValues release];
	[minValues release];
	[timeSliceColors release];
	[aggregatedValues release];
	[timeSliceDurations release];
	[super dealloc];
}

- (void) setTimeSliceColors: (NSMutableDictionary *) colors
{
	if (timeSliceColors){
		[timeSliceColors release];
	}
	timeSliceColors = colors;
	[timeSliceColors retain];
}

- (NSMutableDictionary *) timeSliceColors
{
	return timeSliceColors;
}

- (void) setTimeSliceValues: (NSMutableDictionary *) values
{
	if (timeSliceValues){
		[timeSliceValues release];
	}
	timeSliceValues = values;
	[timeSliceValues retain];
}
- (NSMutableDictionary *) timeSliceValues
{
	return timeSliceValues;
}

- (void) setAggregatedValues: (NSMutableDictionary *) aggValues
{
	if (aggregatedValues){
		[aggregatedValues release];
	}
	aggregatedValues = aggValues;
	[aggregatedValues retain];
}

- (NSMutableDictionary *) aggregatedValues
{
	return aggregatedValues;
}

- (void) setTimeSliceDurations: (NSMutableDictionary *) d
{
	[timeSliceDurations release];
	timeSliceDurations = d;
	[timeSliceDurations retain];
}

-  (NSMutableDictionary *) timeSliceDurations
{
	return timeSliceDurations;
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
	return name;
//	return [NSString stringWithFormat: @"%@-%@", name, aggregatedValues];
}

- (void) testTree
{
	int i;
	if ([children count] != 0){
		for (i = 0; i < [children count]; i++){
			[[children objectAtIndex: i] testTree];
		}
	}
	NSLog (@"%@ - %@ - %.2f", name, timeSliceColors, finalValue);
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

	/* for max and min values */
	[maxValues addEntriesFromDictionary:
		[[children objectAtIndex: 0] maxValues]];
	[minValues addEntriesFromDictionary:
		[[children objectAtIndex: 0] minValues]];
	for (i = 1; i < [children count]; i++){
		TimeSliceTree *child = [children objectAtIndex: i];
		NSDictionary *maxChild = [child maxValues];
		NSDictionary *minChild = [child minValues];
		NSEnumerator *keys = [maxValues keyEnumerator];
		id key;
		while ((key = [keys nextObject])){
			double max = 0, min = FLT_MAX;
			double cmax = 0, cmin = FLT_MAX;

			//checking child max,min
			if ([maxChild objectForKey: key]){
				max = [[maxValues objectForKey:key]doubleValue];
			}
			if ([minChild objectForKey: key]){
				min = [[minValues objectForKey:key]doubleValue];
			}

			//checking mine max,min
			if ([maxValues objectForKey: key]){
				cmax =[[maxValues objectForKey:key]doubleValue];
			}
			if ([minValues objectForKey: key]){
				cmin =[[minValues objectForKey:key]doubleValue];
			}

			if (max > cmax){
				[maxValues setObject:[maxChild objectForKey:key]
					forKey: key];
			}
			if (min < cmin){
				[minValues setObject:[minChild objectForKey:key]
					forKey: key];

			}
		}
	}

	//do the magic to define colors for this node
	NSEnumerator *en;
	id child;
	en = [children objectEnumerator];
	NSMutableDictionary *colors = [NSMutableDictionary dictionary];
	//TODO: merge this loop with the previous for
	while ((child = [en nextObject])){
		[colors addEntriesFromDictionary: [child timeSliceColors]];
	}
	[self setTimeSliceColors: colors];
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

- (void) addChild: (TimeSliceTree*) child
{
	id values = [child timeSliceValues];
	NSEnumerator *en = [values keyEnumerator];
	id key;
	while ((key = [en nextObject])){
		double max = 0, min = FLT_MAX, current;
		current = [[values objectForKey: key] doubleValue];
		if ([maxValues objectForKey: key]){
			max = [[maxValues objectForKey: key] doubleValue];
		}
		if ([minValues objectForKey: key]){
			min = [[minValues objectForKey: key] doubleValue];
		}
		if (current > max){
			[maxValues setObject: [values objectForKey: key]
					forKey: key];
		}
		if (current < min){
			[minValues setObject: [values objectForKey: key]
					forKey: key];
		}
	}
	[super addChild: child];
}

- (NSDictionary *) maxValues
{
	return maxValues;
}

- (NSDictionary *) minValues
{
	return minValues;
}


- (id)copyWithZone:(NSZone *)z
{
	[self retain];
	return self;
}

- (BOOL) isEqual: (id) another
{
	return [name isEqualToString: [another name]];
}
@end
