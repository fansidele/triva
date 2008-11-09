#include "TreeValue.h"

@implementation TreeValue
- (id) init
{
	self = [super init];
	value = 0;
	return self;
}

- (float) value;
{
	return value;
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
@end
