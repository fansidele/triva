#include "Treemap.h"
#include <float.h>

#define BIGFLOAT FLT_MAX

@implementation TreemapRect
- (float) width { return width; }
- (float) height { return height; }
- (float) x { return x; }
- (float) y { return y; }
- (void) setWidth: (float) w { width = w; }
- (void) setHeight: (float) h { height = h; }
- (void) setX: (float) xis { x = xis;}
- (void) setY: (float) ipslon { y = ipslon;}
- (NSString *) description 
{
	return [NSString stringWithFormat: @"%f,%f - size %f,%f",
			x, y, width, height];
}
@end

@implementation Treemap
- (id) init
{
	self = [super init];
	rect = [[TreemapRect alloc] init];
	value = 0;
	return self;
}

- (void) setValue: (float) v
{
	value = v;
}

- (float) val
{
	return value;
}

- (void) dealloc
{
	[rect release];
	[super dealloc];
}

- (TreemapRect *) treemapRect
{
	return rect;
}

- (void) setTreemapRect: (TreemapRect *)r
{
	if (rect != nil){
		[rect release];
	}
	rect = r;
	[rect retain];
}

- (void) setPajeEntity: (id) entity
{
	pajeEntity = entity; //not retained
}

- (id) pajeEntity
{
	return pajeEntity;
}

- (NSArray *) aggregatedChildren
{
	return aggregatedChildren;
}

- (double) worstf: (NSArray *) list
		withSmallerSize: (double) w
		withFactor: (double) factor
{
	double rmax = 0, rmin = FLT_MAX, s = 0;
	int i;
	for (i = 0; i < [list count]; i++){
		Treemap *child = (Treemap *)[list objectAtIndex: i];
		double childValue = [child val]*factor;
		rmin = rmin < childValue ? rmin : childValue;
		rmax = rmax > childValue ? rmax : childValue;
		s += childValue;
	}
	s = s*s; w = w*w;
	double first = w*rmax/s, second = s/(w*rmin);
	return first > second ? first : second;
}


- (TreemapRect *)layoutRow: (NSArray *) row
		withSmallerSize: (double) w
		withinRectangle: (TreemapRect *) r
		withFactor: (double) factor
{
	double s = 0; // sum
	int i;
	for (i = 0; i < [row count]; i++){
		s += [(Treemap *)[row objectAtIndex: i] val]*factor;
	}
	double x = [r x], y = [r y], d = 0;
	double h = w==0 ? 0 : s/w;
	BOOL horiz = (w == [r width]);

	for (i = 0; i < [row count]; i++){
		Treemap *child = (Treemap *)[row objectAtIndex: i];
		if (horiz){
			[[child treemapRect] setX: x+d];
			[[child treemapRect] setY: y];
		}else{
			[[child treemapRect] setX: x];
			[[child treemapRect] setY: y+d];
		}
		double nw = [child val]*factor/h;
		if (horiz){
			[[child treemapRect] setWidth: nw];
			[[child treemapRect] setHeight: h];
			d += nw;
		}else{
			[[child treemapRect] setWidth: h];
			[[child treemapRect] setHeight: nw];
			d += nw;
		}
	}
	if (horiz){
		[r setX: x];
		[r setY: y+h];
		[r setWidth: [r width]];
		[r setHeight: [r height]-h];
	}else{
		[r setX: x+h];
		[r setY: y];
		[r setWidth: [r width]-h];
		[r setHeight: [r height]];
	}
	return r;
}

- (void) squarifyWithOrderedChildren: (NSMutableArray *) list
		andSmallerSize: (double) w
		andFactor: (double) factor
{
	NSMutableArray *row = [NSMutableArray array];
	double worst = FLT_MAX, nworst;
	/* make a copy of my rect, so the algorithm can modify it */
	TreemapRect *r = [[TreemapRect alloc] init];
	[r setWidth: [rect width]];
	[r setHeight: [rect height]];
	[r setX: [rect x]];
	[r setY: [rect y]];

	while ([list count] > 0){
		/* check if w is still valid */
		if (w < 1){
			/* w should not be smaller than 1 pixel
			   no space left for other children to appear */
			break;
		}

		[row addObject: [list objectAtIndex: [list count]-1]];
		nworst = [self worstf: row withSmallerSize: w
					withFactor: factor];
		if (nworst <= 1){
			/* nworst should not be smaller than ratio 1,
                           which is the perfect square */
			break;
		}
		if (nworst <= worst){
			[list removeLastObject];
			worst = nworst;
		}else{
			[row removeLastObject];
			[self layoutRow: row withSmallerSize: w
				withinRectangle: r withFactor: factor];//layout current row
			w = [r width] < [r height] ? [r width] : [r height];
			[row removeAllObjects];
			worst = FLT_MAX;
		}
	}
	if ([row count] > 0){
		r = [self layoutRow: row withSmallerSize: w
			withinRectangle: r withFactor: factor];
		[row removeAllObjects];
	}
	[r release];
}

- (void) calculateTreemapRecursiveWithFactor: (double) factor
{
	/* make ascending order of children by value */
	NSMutableArray *sortedCopy = [NSMutableArray array];
	[sortedCopy addObjectsFromArray: 
		[children sortedArrayUsingSelector:
						@selector(compareValue:)]];
	NSMutableArray *sortedCopyAggregated = [NSMutableArray array];
	[sortedCopyAggregated addObjectsFromArray:
		[aggregatedChildren sortedArrayUsingSelector:
						@selector(compareValue:)]];

	/* remove children with value equal to zero */
	int i;
	for (i = 0; i < [sortedCopy count]; i++){
		if ([[sortedCopy objectAtIndex: i] val] != 0){
			break;
		}
	}
	NSRange range;
	range.location = 0;
	range.length = i;
	[sortedCopy removeObjectsInRange: range];
	
	/* remove aggregated children with value equal to zero */
	for (i = 0; i < [sortedCopyAggregated count]; i++){
		if ([[sortedCopyAggregated objectAtIndex: i] val] != 0){
			break;
		}
	}
	range.location = 0;
	range.length = i;
	[sortedCopyAggregated removeObjectsInRange: range];

	/* calculate the smaller size */
	double w = [rect width] < [rect height] ? [rect width] : [rect height];

	/* call my squarified method with:
		- the list of children with values dif from zero
		- the smaller size
		- the copy of my rect
		- and factor */
	[self squarifyWithOrderedChildren: sortedCopy
			andSmallerSize: w
			andFactor: factor];
	/* call also to set the rectangles of aggregated children */
	[self squarifyWithOrderedChildren: sortedCopyAggregated
			andSmallerSize: w
			andFactor: factor];

	for (i = 0; i < [children count]; i++){
		[[children objectAtIndex: i]
			calculateTreemapRecursiveWithFactor: factor];
	}
	return;
}

/*
 * Entry method
 */
- (void) calculateTreemapWithWidth: (float) w
			andHeight: (float) h
{
        if (value == 0){
                //nothing to calculate
                return;
        }
        double area = w * h;
        double factor = area/value;

        [rect setWidth: w];
        [rect setHeight: h];
        [rect setX: 0];
        [rect setY: 0];
        [self calculateTreemapRecursiveWithFactor: factor];
}

/*
 * Search method
 */
- (Treemap *) searchWithX: (long) x
		andY: (long) y
		limitToDepth: (int) d
		andSelectedValues: (NSSet *) values
{
	Treemap *ret = nil;
	if (x >= [rect x] &&
	    x <= [rect x]+[rect width] &&
	    y >= [rect y] &&
	    y <= [rect y]+[rect height]){
		if ([self depth] == d){
			/* recurse to aggregated children */
			unsigned int i;
			for (i = 0; i < [aggregatedChildren count]; i++){
				Treemap *child = [aggregatedChildren
							objectAtIndex: i];
				if ([child val] &&
					x >= [[child treemapRect] x] &&
				        x <= [[child treemapRect] x]+
						[[child treemapRect] width] &&
 					y >= [[child treemapRect] y] &&
				        y <= [[child treemapRect] y]+
						[[child treemapRect] height]){
						ret = child;
						break;
				}
			}
		}else{
			/* recurse to ordinary children */
			unsigned int i;
			for (i = 0; i < [children count]; i++){
				Treemap *child;
				child = [children objectAtIndex: i];
				if ([child val]){
					ret = [child searchWithX: x
					      andY: y limitToDepth: d
						andSelectedValues: values];
					if (ret != nil){
						break;
					}
				}
			}
		}
	}
	return ret;
}

- (NSComparisonResult) compareValue: (Treemap *) other
{
        if (value < [other val]){
                return NSOrderedAscending;
        }else if (value > [other val]){
                return NSOrderedDescending;
        }else{
                return NSOrderedSame;
        }
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"%@_%.2f", name, value];
}

- (void) testTree
{
        int i;
        if ([children count] != 0){
                for (i = 0; i < [children count]; i++){
                        [[children objectAtIndex: i] testTree];
                }
        }
        NSLog (@"%@ - %@ %.2f", name, rect, [self val]);
}

- (Treemap *) createTreeWithTimeSliceTree: (TimeSliceTree *) orig
	withValues: (NSSet *) values
{
	[self setName: [orig name]];
        [self setValue: [orig finalValue]];
        [self setDepth: [orig depth]];
        [self setMaxDepth: [orig maxDepth]];

	/* create aggregated children */
	if (aggregatedChildren){
		[aggregatedChildren release];
	}
	aggregatedChildren = [[NSMutableArray alloc] init];

	NSDictionary *aggValues = [orig aggregatedValues];
	NSDictionary *aggEntities = [orig pajeEntities];
	NSEnumerator *keys = [aggValues keyEnumerator];
	id key;
	while ((key = [keys nextObject])){
		if ([values count] != 0){
			if ([values containsObject: key]){
				Treemap *aggNode = [[Treemap alloc] init];
				[aggNode setName: key];
				[aggNode setValue: [[aggValues objectForKey: key] floatValue]];
				[aggNode setDepth: [orig depth] + 1];
				[aggNode setMaxDepth: [orig maxDepth]];
				[aggNode setPajeEntity: [aggEntities objectForKey: key]];
				[aggNode setParent: self];
				[aggregatedChildren addObject: aggNode];
				[aggNode release];
			}
		}else{
			Treemap *aggNode = [[Treemap alloc] init];
			[aggNode setName: key];
			[aggNode setValue: [[aggValues objectForKey: key] floatValue]];
			[aggNode setDepth: [orig depth] + 1];
			[aggNode setMaxDepth: [orig maxDepth]];
			[aggNode setPajeEntity: [aggEntities objectForKey: key]];
			[aggNode setParent: self];
			[aggregatedChildren addObject: aggNode];
			[aggNode release];
		}
	}

	/* recurse normally */
	int i;
	for (i = 0; i < [[orig children] count]; i++){
		Treemap *node = [[Treemap alloc] init];
		node = [node createTreeWithTimeSliceTree:
				[[orig children] objectAtIndex: i]
				withValues: values];
		[node setParent: self];
		[children addObject: node];
		[node release];
	}
	return self;
}
@end
