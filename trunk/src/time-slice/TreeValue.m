#include "TreeValue.h"

@implementation TreeValue
- (id) init
{
	self = [super init];
	value = 0;
	usedValue = 0;
	return self;
}

- (float) val
{
	return value;
}

- (float) usedVal
{
	return usedValue;
}

- (NSComparisonResult) compareUsedValue: (TreeValue *) other
{
	if (usedValue < [other usedVal]){
		return NSOrderedAscending;
	}else if (usedValue > [other usedVal]){
		return NSOrderedDescending;
	}else{
		return NSOrderedSame;
	}
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

- (float) setUsedValue: (float) v
{
	usedValue = v;
	return usedValue;
}

- (float) addValue: (float) v
{
	value += v;
	return value;
}

- (float) addUsedValue: (float) v
{
	usedValue += v;
	return usedValue;
}

- (float) subtractValue: (float) v
{
	value -= v;
	return value;
}

/**
  * This method only resets the usedValue attribute
  */
- (void) recursiveResetValues
{
	if ([children count] == 0){
		//leaf nodes must always keep their values
	}else{
		int i;
		for (i = 0; i < [children count]; i++){
			TreeValue *child = [children objectAtIndex: i];
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
	/* must know the pajeEntity, so super class must implement */
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

- (NSString *) description
{
	return [NSString stringWithFormat: @"%@(%.3f)(%.3f)",
			name, value, usedValue];
}
@end
