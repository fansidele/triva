#include "Tree.h"

@implementation Tree
- (id) init
{
	self = [super init];
	children = [[NSMutableArray alloc] init];
	return self;
}

- (NSString *) name
{
	return name;
}

- (NSArray *) children
{
	return children;
}

- (Tree *) parent
{
	return parent;
}

- (void) setName: (NSString *) n
{
	if (name != nil){
		[name release];
	}
	name = n;
	[name retain];
}

- (void) setParent: (Tree *) p
{
	if (parent != nil){
		[parent release];
	}
	parent = p;
	[parent retain];
}

- (void) addChild: (Tree *) c
{
	[children addObject: c];
}

- (void) dealloc
{
	[name release];
	[parent release];
	[children release];
	[super dealloc];
}
@end
