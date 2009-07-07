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
	aggregatedChildren = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc
{
	[rect release];
	[super dealloc];
}

- (TreemapRect *) rect
{
	return rect;
}

- (void) setRect: (TreemapRect *)r
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

- (double) worstf: (NSArray *) list
		withSmallerSize: (double) w
		withFactor: (double) factor
{
	double rmax = 0, rmin = FLT_MAX, s = 0;
	int i;
	for (i = 0; i < [list count]; i++){
		Treemap *child = (Treemap *)[list objectAtIndex: i];
		double childValue = [child usedVal]*factor;
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
		s += [(Treemap *)[row objectAtIndex: i] usedVal]*factor;
	}
	double x = [r x], y = [r y], d = 0;
	double h = w==0 ? 0 : s/w;
	BOOL horiz = (w == [r width]);

	for (i = 0; i < [row count]; i++){
		Treemap *child = (Treemap *)[row objectAtIndex: i];
		if (horiz){
			[[child rect] setX: x+d];
			[[child rect] setY: y];
		}else{
			[[child rect] setX: x];
			[[child rect] setY: y+d];
		}
		double nw = [child usedVal]*factor/h;
		if (horiz){
			[[child rect] setWidth: nw];
			[[child rect] setHeight: h];
			d += nw;
		}else{
			[[child rect] setWidth: h];
			[[child rect] setHeight: nw];
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
						@selector(compareUsedValue:)]];
	NSMutableArray *sortedCopyAggregated = [NSMutableArray array];
	[sortedCopyAggregated addObjectsFromArray:
		[aggregatedChildren sortedArrayUsingSelector:
						@selector(compareUsedValue:)]];

	/* remove children with usedVal equal to zero */
	int i;
	for (i = 0; i < [sortedCopy count]; i++){
		if ([[sortedCopy objectAtIndex: i] usedVal] != 0){
			break;
		}
	}
	NSRange range;
	range.location = 0;
	range.length = i;
	[sortedCopy removeObjectsInRange: range];
	
	/* remove aggregated children with usedVal equal to zero */
	for (i = 0; i < [sortedCopyAggregated count]; i++){
		if ([[sortedCopyAggregated objectAtIndex: i] usedVal] != 0){
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
        if (usedValue == 0){
                //nothing to calculate
                return;
        }
        double area = w * h;
        double factor = area/usedValue;

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
	/* Check to see if x,y are in my area */
	if (x >= [rect x] &&
	    x <= [rect x]+[rect width] &&
	    y >= [rect y] &&
	    y <= [rect y]+[rect height]){
		/* It is in my area, so let's see if I am a leaf-node 
			and my pajeEntity is contained in the NSSet */
		if ([children count] == 0 && (
			[values containsObject: [[self pajeEntity] value]]
			|| [values count] == 0)){
			/* I am a leaf node, good! They searched for me */
			ret = self;
		}
	}
	if (ret == nil){
		/* it's not in my area, and it's not me, recurse to children */
		/* but first, check if the search is over an agg children */
		if ([self depth] == d){
			/* recurse to aggregated children */
			unsigned int i;
			for (i = 0; i < [aggregatedChildren count]; i++){
				Treemap *child = [aggregatedChildren
							objectAtIndex: i];
				if ([child usedVal] &&
					([values containsObject:
						[[child pajeEntity] value]] ||
					[values count] == 0)){
					ret = [child searchWithX: x
						andY: y limitToDepth: d
						     andSelectedValues: values];
					if (ret != nil){
						break;
					}
				}
			}
		}else{
			if ([children count] != 0){
				/* recurse to ordinary children */
				unsigned int i;
				for (i = 0; i < [children count]; i++){
					Treemap *child;
					child = [children objectAtIndex: i];
					if ([child usedVal]){
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
	}
	return ret;
}

/* Aggregated Children Methods */
- (void) addAggregatedChild: (Treemap *) child
{
	[aggregatedChildren addObject: child];
}

- (void) removeAllAggregatedChildren
{
	[aggregatedChildren removeAllObjects];
}

- (void) recursiveRemoveAllAggregatedChildren
{
	[self removeAllAggregatedChildren];
	int i;
	for (i = 0; i < [children count]; i++){
		[[children objectAtIndex: i] recursiveRemoveAllAggregatedChildren];
	}
}

- (NSArray *) aggregatedChildren
{
	return aggregatedChildren;
}

/* Re-implementing method of TreeValue since we need the pajeEntity from 
 * Treemap class to know how to recalculate the values of the tree
 */
- (void) recalculateRecursiveBottomUpWithValues: (NSSet *) values
{
	if ([children count] == 0){
		if ([values containsObject: [[self pajeEntity] value]]
                        	|| [values count] == 0){
	                usedValue = value;
		}else{
			usedValue = 0;
		}
	}else{
		float nvalue = 0;
		int i;
		for (i = 0; i < [children count]; i++){
		        TreeValue *child = [children objectAtIndex: i];
		        [child recalculateRecursiveBottomUpWithValues: values];
		        nvalue += [child usedVal];
		}
		if (nvalue > 0){
		        usedValue = nvalue;
		}
	}
}
@end
