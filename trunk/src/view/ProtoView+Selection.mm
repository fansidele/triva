#include "ProtoView.h"

@implementation ProtoView (Selection)
- (void) selectObjectIdentifier: (NSString *) identifier
{
	static XState *prev = nil;

	XState *s = (XState *)[super objectWithIdentifier: identifier];
	if (s){
		NSMutableString *str = [NSMutableString string];
		[str appendString: [NSString stringWithFormat: @"%@\n", [s type]]];
		[str appendString: [NSString stringWithFormat: @"%@\n", [s start]]];
		[str appendString: [NSString stringWithFormat: @"%@\n", [s end]]];

		if (prev){
			drawManager->unselectState (prev);
		}
		drawManager->selectState (s);
		prev = s;

	}
}


- (void) unselectObjectIdentifier: (NSString *) identifier
{
//	NSLog (@"%s %@", __FUNCTION__, identifier);
}
@end
