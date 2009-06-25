#include "TreeValue.h"

@implementation TreeValue
- (id) init
{
	self = [super init];
	value = 0;
	return self;
}

- (float) val;
{
	return value;
}

- (NSComparisonResult) compareValue: (TreeValue *) other
{
	if (value < [other val]){
		return NSOrderedAscending;
	}else if (value > [other val]){
		return NSOrderedDescending;
	}else{
		return NSOrderedSame;
	}
}

- (float) setValue: (float) v
{
	value = v;
	return value;
}

- (float) addValue: (float) v
{
	value += v;
	return value;
}

- (float) subtractValue: (float) v
{
	value -= v;
	return value;
}

- (void) recursiveResetValues
{
	if ([children count] == 0){
		//leaf nodes must always keep their values
	}else{
		value = 0;
		int i;
		for (i = 0; i < [children count]; i++){
			TreeValue *child = [children objectAtIndex: i];
			[child recursiveResetValues];
		}
	}
}

- (void) recalculateValuesBottomUp
{
	if ([children count] == 0){
		return;
	}
	float nvalue = 0;
	int i;
	for (i = 0; i < [children count]; i++){
		TreeValue *child = [children objectAtIndex: i];
		[child recalculateValuesBottomUp];
		nvalue += [child val];
	}
	if (nvalue > 0){
		value = nvalue;
	}
}

- (void) recalculateValues
{
	[self recursiveResetValues];
	[self recalculateValuesBottomUp];
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"%f", value];
}
@end
