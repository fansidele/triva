#include "ProtoMemory.h"

@implementation ProtoMemory
- (id) init
{
	self = [super init];
	objects = [[NSMutableArray alloc] init];
	readIndex = 0;
	return self;
}

- (void) dealloc
{
	[objects release];
	[super dealloc];
}

- (void) input: (id) object
{
	[objects addObject: object];
	NSLog (@"%@ - %@", object, [object identifier]);
}

/*
- (ProtoObject *) nextObject
{
	if (readIndex < [objects count]){
		ProtoObject *ret = [objects objectAtIndex: readIndex];
		readIndex++;
		return ret;
	}else{
		return nil;
	}
}
*/
@end
