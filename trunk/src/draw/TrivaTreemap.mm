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
	unsigned int i, j;
	NSArray *ar = [tree objectForKey: @"children"];
	value = 0;
	for (i = 0; i < [ar count]; i++){
		TrivaTreemap *child = [TrivaTreemap treemapWithDictionary: [ar objectAtIndex: i]];
		float val = [child value];
		/* find position for child */
		for (j = 0; j < [children count]; j++){
			TrivaTreemap *child2 = [children objectAtIndex: j];
			float val2 = [child2 value];
			if (val2 < val){
				break;
			}
		}
		/* insert at position j */
		[children insertObject: child atIndex: j];
		[child setParent: self];
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

- (id) searchWithPartialName: (NSString *) partialName
{
	if (children != nil){
		unsigned int i;
		for (i = 0; i < [children count]; i++){
			id ret = [[children objectAtIndex: i]
				searchWithPartialName: partialName];
			if (ret != nil){
				return ret;
			}
		}
		return nil;
	}

	NSString *aux = [[partialName componentsSeparatedByString: @"_"]
				lastObject];
	NSRange aaa = NSIntersectionRange ([name rangeOfString: aux],
			[aux rangeOfString: name]);
	if (aaa.location != NSNotFound){
		return self;
	}else{
		return nil;
	}
}

- (void) reorder
{
	if (children == nil){
		return;
	}
	[children sortUsingSelector: @selector(compare:)];
}

- (void) incrementValue
{
	value++;
	[parent reorder];
}

- (void) decrementValue
{
	value--;
	[parent reorder];
}

- (void) recalculateValuesBottomUp
{
	unsigned int i;
	
	if (children == nil){
		return;
	}

	float nvalue = 0;
	for (i = 0; i < [children count]; i++){
		TrivaTreemap *child = [children objectAtIndex: i];
		[child recalculateValuesBottomUp];
		nvalue += [child value];
	}
	if (nvalue > 0){
		value = nvalue;
	}
}

- (void) setParent: (TrivaTreemap *) p
{
	parent = p;
}

- (NSComparisonResult) compare: (TrivaTreemap *) other
{
	if (value < [other value]){
		return NSOrderedAscending;
	}else if (value > [other value]){
		return NSOrderedDescending;
	}else{
		return NSOrderedSame;
	}
}
@end
