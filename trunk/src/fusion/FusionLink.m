#include "FusionLink.h"

@implementation FusionLink
- (id)initWithType:(PajeEntityType *)type
              name:(NSString *)n
         container:(PajeContainer *)c
{
	self = [super initWithType: type name: n container: c];
	if (self != nil){
		sourceContainer = nil;
		destContainer = nil;
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

- (void) setSourceContainer: (PajeContainer *) cont
{
	if (sourceContainer != nil){
		[sourceContainer release];
	}
	sourceContainer = cont;
	[sourceContainer retain];
}

- (void) setDestContainer: (PajeContainer *) cont
{
	if (destContainer != nil){
		[destContainer release];
	}
	destContainer = cont;
	[destContainer retain];
}

- (PajeContainer *) sourceContainer
{
	return sourceContainer;
}

- (PajeContainer *) destContainer
{
	return destContainer;
}
@end
