#ifndef __TREEVALUE_H_
#define __TREEVALUE_H_
#include <Foundation/Foundation.h>
#include "Tree.h"

@interface TreeValue : Tree 
{
	float value; /* this contains the value generated by the timeslice */
	float usedValue;  /* this contains the value used by the treemap algo */
}
- (float) val;
- (float) usedVal;
- (float) setValue: (float) v;
- (float) setUsedValue: (float) v;
- (float) addValue: (float) v;
- (float) addUsedValue: (float) v;
- (float) subtractValue: (float) v;

- (NSComparisonResult) compareValue: (TreeValue *) other;
- (NSComparisonResult) compareUsedValue: (TreeValue *) other;

- (void) recursiveResetValues;
- (void) recalculateRecursiveBottomUpWithValues: (NSSet *) values;
- (void) recalculateWithValues: (NSSet *) values;
@end

#endif
