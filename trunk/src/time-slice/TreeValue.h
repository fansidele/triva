#include <Foundation/Foundation.h>
#include "Tree.h"

@interface TreeValue : Tree 
{
	float value;
}
- (float) value;
- (float) setValue: (float) v;
- (float) addValue: (float) v;

- (void) recursiveResetValues;
- (void) recalculateValuesBottomUp;
- (void) recalculateValues;
@end
