#include "TrivaGraphNode.h"

@implementation TrivaGraphNode
- (id) init
{
	self = [super init];
	name = nil;
	position = NSZeroPoint;
	size = NSZeroRect;
	values = nil;
	return self;
}

- (void) setName: (NSString *) n
{
	[name release];
	name = n;
	[name retain];
}

- (NSString *) name
{
	return name;
}

- (NSRect) size
{
	return size;
}

- (void) setSize: (NSRect) r
{
	size = r;
}

- (NSPoint) position
{
	return position;
}

- (void) setPosition: (NSPoint) p
{
	position = p;
}

- (void) setValues: (NSDictionary*)v
{
	[values release];
	values = v;
	[values retain];
}

- (NSDictionary*) values
{
	return values;
}

- (void) dealloc
{
	[name release];
	[values release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
	TrivaGraphNode *ret = [[TrivaGraphNode alloc] init];
	[ret setName: name];
	[ret setValues: values];
	return [ret autorelease];
}
@end
