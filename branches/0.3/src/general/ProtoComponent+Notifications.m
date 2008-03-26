#include "ProtoComponent.h"

@implementation ProtoComponent (Notifications)
- (void) timeLimitsChanged
{
	[output timeLimitsChanged];
}

- (void) hierarchyChanged
{
	[output hierarchyChanged];
}

- (void) endOfData
{
	[output endOfData];
}

- (void) connectionsChanged
{
	[output connectionsChanged];
}
@end
