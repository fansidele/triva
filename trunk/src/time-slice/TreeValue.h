#ifndef __TREEVALUE_H_
#define __TREEVALUE_H_
#include <Foundation/Foundation.h>
#include "Tree.h"

@interface TreeValue : Tree 
{
	float value;
}
- (float) value;
- (float) setValue: (float) v;
- (float) addValue: (float) v;
- (float) subtractValue: (float) v;

- (void) recursiveResetValues;
- (void) recalculateValuesBottomUp;
- (void) recalculateValues;
@end

#endif
