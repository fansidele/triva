#include "FusionState.h"

@implementation FusionState
- (id)initWithType:(PajeEntityType *)type
              name:(NSString *)n
         container:(PajeContainer *)c
{
	self = [super initWithType: type name: n container: c];
	if (self != nil){
		//
	}
	return self;
}

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

- (NSDate *) time
{
	return endTime;
}

- (void) setName: (NSString *) n
{
	if (name != nil){
		[name release];
	}
	name = n;
	[name retain];
}
@end
