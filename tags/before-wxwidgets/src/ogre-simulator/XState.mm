#include "XState.h"

@implementation XState
- (id) init
{
	self = [super init];
	finalized = NO;
	start = nil;
	end = nil;
	return self;
}

- (BOOL) finalized
{
	return finalized;
}

- (void) setFinalized: (BOOL) v
{
	finalized = v;
}

- (void) setLayout: (Layout *) lay
{
	[super setLayout: lay];
	[layout createWithIdentifier: identifier andMaterial: type];
	[layout attachTo: node];
	[self updateLayout];
}	

- (void) updateLayout
{
//	NSLog (@"%s start=%@ end=%@", __FUNCTION__, start, end);
	[layout setStart: [start doubleValue]];
	if (end != nil){
		[layout setEnd: [end doubleValue]];
	}else{
		[layout setEnd: [start doubleValue]];
	}
//	if (finalized){
		[layout redraw];
//	}
}
@end
