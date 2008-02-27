#include "XContainer.h"

@implementation XContainer (Search)
- (XState *) stateWithIdentifier: (NSString *) ide
{
	unsigned int i;
	for (i = 0; i < [states count]; i++){
		XState *s = (XState *)[states objectAtIndex: i];
		if ([ide isEqual: [s identifier]]){
			return s;
		}
	}

	for (i = 0; i < [subContainers count]; i++){
		XObject *ret = nil;
		XContainer *sub = (XContainer *)[subContainers objectAtIndex:i];
		ret = [sub stateWithIdentifier: ide];
		if (ret != nil){
			return ret;
		}
	}
	return nil;
}
@end
