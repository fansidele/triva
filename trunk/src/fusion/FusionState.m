#include "FusionState.h"

@implementation FusionState
- (NSDate *) startTime
{
	return startTime;
}

- (NSDate *) endTime
{
	return endTime;
}

- (void) setStartTime: (NSDate *) time
{
	startTime = time;
}

- (void) setEndTime: (NSDate *) time
{
	endTime = time;
}
@end
