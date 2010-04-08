#ifndef __TIMESLICETREE_H_
#define __TIMESLICETREE_H_

#include <Foundation/Foundation.h>
#include "Tree.h"

@interface TimeSliceTree : Tree
{
	/* to be used by the time-slice algorithm */
	NSMutableDictionary *timeSliceValues;
	float finalValue;

	/* registering colors */
	NSMutableDictionary *timeSliceColors;

	/* for Aggregation category */
	NSMutableDictionary *aggregatedValues;

	/* for registering accumulated durations */
	NSMutableDictionary *timeSliceDurations;
}
- (void) setTimeSliceColors: (NSMutableDictionary *) colors;
- (NSMutableDictionary *) timeSliceColors;
- (void) setTimeSliceValues: (NSMutableDictionary *) values;
- (NSMutableDictionary *) timeSliceValues;
- (void) setAggregatedValues: (NSMutableDictionary *) aggValues;
-  (NSMutableDictionary *) timeSliceDurations;
- (void) setTimeSliceDurations: (NSMutableDictionary *) d;
- (NSMutableDictionary *) aggregatedValues;
- (NSComparisonResult) compareValue: (TimeSliceTree *) other;
- (float) finalValue;
- (void) setFinalValue: (float) f;
- (void) doAggregation;
- (float) doFinalValueWith: (NSSet *) set;
@end
#endif
