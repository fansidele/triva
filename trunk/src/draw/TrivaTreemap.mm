#include "TrivaTreemap.h"

@implementation TrivaTreemap
+ (id) treemapWithDictionary: (id) tree
{
        if ([tree isKindOfClass: [NSDictionary class]]){
		TrivaTreemap *ret;
		ret = [[TrivaTreemap alloc] initWithDictionary: tree];
		return ret;
        }else if ([tree isKindOfClass: [NSString class]]){
		TrivaTreemap *ret;
		ret = [[TrivaTreemap alloc] initWithString: tree];
		return ret;
        }else{
		NSLog (@"eh outra %@", [tree class]);
        }
        return nil;
}

- (id) initWithDictionary: (id) tree
{
	self = [super init];
	[name = [tree objectForKey: @"name"] retain];
	[type = [tree objectForKey: @"type"] retain];
	children = [[NSMutableArray alloc] init];
	unsigned int i;
	NSArray *ar = [tree objectForKey: @"children"];
	value = 0;
	for (i = 0; i < [ar count]; i++){
		[children addObject: [TrivaTreemap treemapWithDictionary: [ar objectAtIndex: i]]];
		TrivaTreemap *child = [children objectAtIndex: i];
		value += [child value];
	}
	return self;
}

- (id) initWithString: (id) tree
{
	self = [super init];
	name = tree;
	[name retain];
	children = nil;
	value = 0;
	type = nil;
	width = height = x = y = depth = -1;
	return self;
}

- (void) dealloc
{
	[name release];
	[type release];
	[children release];
	[super dealloc];
}

- (float) value
{
	return value;
}

- (float) width
{
	return width;
}

- (float) height
{
	return height;
}

- (float) x
{
	return x;
}

- (float) y
{
	return y;
}

- (float) depth
{
	return depth;
}

- (void) setWidth: (float) w
{
	width = w;
}

- (void) setHeight: (float) h
{
	height = h;
}

- (void) setX: (float) xp
{
	x = xp;
}

- (void) setY: (float) yp
{
	y = yp;
}

- (void) setDepth: (float) d
{
	depth = d;
}

- (NSString *) name
{
	return name;
}

- (NSString *) type
{
	return type;
}

- (NSArray *) children
{
	return children;
}

- (void) navigate
{
        NSLog (@"name:%@ area (%.1f x %.1f) x=%.1f y=%.1f",
                name, width, height, x, y);
        if (type == nil){
                return;
        }
        if (children != nil){
                unsigned int i;
                for (i = 0; i < [children count]; i++){
                        [[children objectAtIndex: i] navigate];
                }
        }
}
@end
