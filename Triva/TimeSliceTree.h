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
#ifndef __TIMESLICETREE_H_
#define __TIMESLICETREE_H_

#include <Foundation/Foundation.h>
#include "Tree.h"

@class TimeSliceGraph;

@interface TimeSliceTree : Tree
{
	/* to be used by the time-slice algorithm */
	NSMutableDictionary *timeSliceValues;
	float finalValue;

	/* max and min values */
	NSMutableDictionary *maxValues;
	NSMutableDictionary *minValues;

	/* registering colors */
	NSMutableDictionary *timeSliceColors;

	/* for Aggregation category */
	NSMutableDictionary *aggregatedValues;

	/* for registering accumulated durations */
	NSMutableDictionary *timeSliceDurations;

	/* for registering graph destinations */
	//(NSString*) -> (TimeSliceGraph*)
	NSMutableDictionary *destinations; 
}
- (NSDictionary *) maxValues;
- (NSDictionary *) minValues;
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
- (float) doFinalValue;

- (void) addChild: (TimeSliceTree*) child;
- (NSMutableDictionary *) destinations;


- (void) doGraphAggregationWithNodeNames: (id) nodeNames;
- (void) mergeGraphDestinationsOfChild: (TimeSliceTree *) child
                        withNodeNames: (NSDictionary *) nodeNames;
@end

#include "TimeSliceGraph.h"
#endif
