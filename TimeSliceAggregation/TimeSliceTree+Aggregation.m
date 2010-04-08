#include "TimeSliceTree.h"

@implementation TimeSliceTree (Aggregation)
/* the following functions must be used to define the single value
that will be used by the treemap algorithm
- (void) recursiveResetValues
{
	if ([children count] == 0){
		//leaf nodes must always keep their values
	}else{
		int i;
		for (i = 0; i < [children count]; i++){
			TimeSliceTree *child = [children objectAtIndex: i];
			[child recursiveResetValues];
		}
		value = 0; //non-leaf nodes have its value reset
	}
	//the usedValue must be set to 0
	//it will be recalculated based on selected values
	usedValue = 0;
}

- (void) recalculateRecursiveBottomUpWithValues: (NSSet *) values
{
        if ([children count] == 0){
                if ([values containsObject: [[self pajeEntity] value]]
                                || [values count] == 0){
                        usedValue = value;
                }else{
                        usedValue = 0;
                }
        }else{
                float nvalue = 0;
                int i;
                for (i = 0; i < [children count]; i++){
                        TimeSliceTree *child = [children objectAtIndex: i];
                        [child recalculateRecursiveBottomUpWithValues:
values];
                        nvalue += [child usedVal];
                }
                if (nvalue > 0){
                        usedValue = nvalue;
                }
        }
	return;
}

- (void) recalculateWithValues: (NSSet *) values
{
	if (values == nil){
		return;
	}

	[self recursiveResetValues];
	[self recalculateRecursiveBottomUpWithValues: values];
}
*/

/* Aggregated Children Methods */
/*
- (void) addAggregatedChild: (TimeSliceTree *) child
{
        [aggregatedChildren addObject: child];
}

- (void) removeAllAggregatedChildren
{
        [aggregatedChildren removeAllObjects];
}

- (void) recursiveRemoveAllAggregatedChildren
{
        [self removeAllAggregatedChildren];
        int i;
        for (i = 0; i < [children count]; i++){
                [[children objectAtIndex: i]
recursiveRemoveAllAggregatedChildren];
        }
}

- (NSArray *) aggregatedChildren
{
        return aggregatedChildren;
}
*/
@end
