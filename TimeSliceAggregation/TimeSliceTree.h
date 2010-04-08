#ifndef __TIMESLICETREE_H_
#define __TIMESLICETREE_H_

#include <Foundation/Foundation.h>
#include "Tree.h"

@interface TimeSliceTree : Tree
{
	/* to be used by the time-slice algorithm */
	NSMutableDictionary *timeSliceValues;
	float finalValue;

	/* associating colors, containers ..., to values */
	NSMutableDictionary *pajeEntities;
	//PajeContainer *pajeContainer;

	/* for Aggregation category */
	NSMutableDictionary *aggregatedValues;
}
- (void) setPajeEntities: (NSMutableDictionary *) entities;
- (NSMutableDictionary *) pajeEntities;
- (void) setTimeSliceValues: (NSMutableDictionary *) values;
- (NSMutableDictionary *) timeSliceValues;
- (void) setAggregatedValues: (NSMutableDictionary *) aggValues;
- (NSMutableDictionary *) aggregatedValues;
- (NSComparisonResult) compareValue: (TimeSliceTree *) other;
- (float) finalValue;
- (void) setFinalValue: (float) f;
- (void) doAggregation;
- (float) doFinalValueWith: (NSSet *) set;
@end


@interface TimeSliceTree (Aggregation)

/*
- (void) recursiveResetValues;
- (void) recalculateRecursiveBottomUpWithValues: (NSSet *) values;
- (void) recalculateWithValues: (NSSet *) values;

- (void) addAggregatedChild: (TimeSliceTree *) child;
- (void) removeAllAggregatedChildren;
- (void) recursiveRemoveAllAggregatedChildren;
- (NSArray *) aggregatedChildren;
*/
@end

@interface TimeSliceTree (Paje)
//- (void) setPajeEntity: (id) entity;
//- (id) pajeEntity;
@end

#endif
