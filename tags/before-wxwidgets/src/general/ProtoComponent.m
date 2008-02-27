#include "ProtoComponent.h"

@implementation ProtoComponent
- (id) init
{
	self = [super init];
	input = nil;
	output = nil;
	return self;
}

- (void) setInput: (ProtoComponent *) inp
{
	input = inp;
	[input retain];	
}

- (void) setOutput: (ProtoComponent *) outp
{
	output = outp;
	[output retain];
}

- (void) input: (id) object
{
	NSLog (@"%s: error", __FUNCTION__);
}

- (void) output: (id) object
{
	if (output != nil){
		[output input: object];
	}
}

- (void) dealloc
{
	NSLog (@"%@ - %s", self, __FUNCTION__);
	[input release];
	[output release];
	[super dealloc];
}

- (BOOL) hasMoreData
{
	return [input hasMoreData];
}
@end
