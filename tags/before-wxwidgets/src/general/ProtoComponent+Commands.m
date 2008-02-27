#include "ProtoComponent.h"

@implementation ProtoComponent (Commands)
- (void) read
{
	[input read];
}

- (BOOL) loadDIMVisualBundle: (NSString *) bundleName
{
	return [input loadDIMVisualBundle: bundleName];
}
@end
