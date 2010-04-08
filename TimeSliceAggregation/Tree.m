#include "Tree.h"

@implementation Tree
- (id) init
{
	self = [super init];
	children = [[NSMutableArray alloc] init];
	maxDepth = -1;
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

- (Tree *) searchChildByName: (NSString *) n
{
	int i;
	//look up among children
	for (i = 0; i < [children count]; i++){
		if ([n isEqualToString: [[children objectAtIndex: i] name]]){
			return [children objectAtIndex: i];
		}
	}
	return nil;
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

- (void) removeAllChildren
{
	[children removeAllObjects];
}

- (int) maxDepth
{
	if (maxDepth != -1){
		return maxDepth;
	}

        if ([children count] == 0){
                return depth;
        }

        int max = 0;
        int i;
        for (i = 0; i < [children count]; i++){
                int d = [[children objectAtIndex: i] maxDepth];
                if (d > max){
                        max = d;
                }
        }
	maxDepth = max;
        return max;
}

- (void) setMaxDepth: (int) d
{
	maxDepth = d;
}

- (int) depth
{
        return depth;
}

- (void) setDepth: (int) d
{
        depth = d;
}
@end
