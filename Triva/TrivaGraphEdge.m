#include "TrivaGraphEdge.h"

@implementation TrivaGraphEdge
- (void) setSource: (TrivaGraphNode *) s;
{
	[source release];
	source = s;
	[source retain];
}

- (void) setDestination: (TrivaGraphNode *) d
{
	[destination release];
	destination = d;
	[destination retain];
}

- (TrivaGraphNode *) source
{
	return source;
}

- (TrivaGraphNode *) destination
{
	return destination;
}

- (void) dealloc
{
	[source release];
	[destination release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
	TrivaGraphEdge *ret = [[TrivaGraphEdge alloc] init];	
	[ret setDestination: destination];
	[ret setSource: source];
	[ret setName: name];
	[ret setValues: values];
	return [ret autorelease];
}
@end
