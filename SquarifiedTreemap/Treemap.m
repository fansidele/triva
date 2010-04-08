/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "Treemap.h"
#include <float.h>

#define BIGFLOAT FLT_MAX

@implementation Treemap
- (id) init
{
	self = [super init];
	rect = NSZeroRect;
	value = 0;
	highlighted = NO;
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
	[aggregatedChildren release];
	[super dealloc];
}

- (NSRect) treemapRect
{
	return rect;
}

- (void) setTreemapRect: (NSRect)r
{
	rect = r;
}

- (void) setColor: (NSColor *) c
{
	color = c;
}

- (NSColor *) color
{
	return color;
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


- (NSRect)layoutRow: (NSArray *) row
		withSmallerSize: (double) w
		withinRectangle: (NSRect) r
		withFactor: (double) factor
{
	double s = 0; // sum
	int i;
	for (i = 0; i < [row count]; i++){
		s += [(Treemap *)[row objectAtIndex: i] val]*factor;
	}
	double x = r.origin.x, y = r.origin.y, d = 0;
	double h = w==0 ? 0 : s/w;
	BOOL horiz = (w == r.size.width);

	for (i = 0; i < [row count]; i++){
		Treemap *child = (Treemap *)[row objectAtIndex: i];
		NSRect childRect;
		if (horiz){
			childRect.origin.x = x+d;
			childRect.origin.y = y;
		}else{
			childRect.origin.x = x;
			childRect.origin.y = y+d;
		}
		double nw = [child val]*factor/h;
		if (horiz){
			childRect.size.width = nw;
			childRect.size.height = h;
			d += nw;
		}else{
			childRect.size.width = h;
			childRect.size.height = nw;
			d += nw;
		}
		[child setTreemapRect: childRect];
	}
	if (horiz){
		r = NSMakeRect (x, y+h, r.size.width, r.size.height-h);
	}else{
		r = NSMakeRect (x+h, y, r.size.width-h, r.size.height);
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
	NSRect r = NSMakeRect (rect.origin.x, rect.origin.y,
				rect.size.width, rect.size.height);

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
			r = [self layoutRow: row withSmallerSize: w
				withinRectangle: r withFactor: factor];//layout current row
			w = r.size.width < r.size.height ?
				r.size.width : r.size.height;
			[row removeAllObjects];
			worst = FLT_MAX;
		}
	}
	if ([row count] > 0){
		r = [self layoutRow: row withSmallerSize: w
			withinRectangle: r withFactor: factor];
		[row removeAllObjects];
	}
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
	double w = rect.size.width < rect.size.height ?
			rect.size.width : rect.size.height;

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

	rect = NSMakeRect (0,0,w,h);
        [self calculateTreemapRecursiveWithFactor: factor];
}

/*
 * Search method
 */
- (Treemap *) searchWith: (NSPoint) point
		limitToDepth: (int) d
{
	double x = point.x;
	double y = point.y;
	Treemap *ret = nil;
	if (x >= rect.origin.x &&
	    x <= rect.origin.x+rect.size.width &&
	    y >= rect.origin.y &&
	    y <= rect.origin.y+rect.size.height){
		if ([self depth] == d){
			// recurse to aggregated children 
			unsigned int i;
			for (i = 0; i < [aggregatedChildren count]; i++){
				Treemap *child = [aggregatedChildren
							objectAtIndex: i];
				if ([child val] &&
					x >= [child treemapRect].origin.x &&
				        x <= [child treemapRect].origin.x+
						[child treemapRect].size.width&&
 					y >= [child treemapRect].origin.y &&
				        y <= [child treemapRect].origin.y+
					    [child treemapRect].size.height){
						ret = child;
						break;
				}
			}
		}else{
			// recurse to ordinary children 
			unsigned int i;
			for (i = 0; i < [children count]; i++){
				Treemap *child;
				child = [children objectAtIndex: i];
				if ([child val]){
					ret = [child searchWith: point
					      limitToDepth: d];
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
	NSDictionary *aggEntities = [orig timeSliceColors];
	NSEnumerator *keys = [aggValues keyEnumerator];
	id key;
	while ((key = [keys nextObject])){
		Treemap *aggNode = [[Treemap alloc] init];
		[aggNode setName: key];
		[aggNode setValue: [[aggValues objectForKey: key] floatValue]];
		[aggNode setDepth: [orig depth] + 1];
		[aggNode setMaxDepth: [orig maxDepth]];
		[aggNode setColor: [aggEntities objectForKey: key]];
		[aggNode setParent: self];
		[aggregatedChildren addObject: aggNode];
		[aggNode release];
		
	}

	/* recurse normally */
	int i;
	for (i = 0; i < [[orig children] count]; i++){
		Treemap *node = [[Treemap alloc] init];
		node = [node createTreeWithTimeSliceTree:
				[[orig children] objectAtIndex: i]];
		[node setParent: self];
		[children addObject: node];
		[node release];
	}
	return self;
}

- (BOOL) highlighted
{
	return highlighted;
}

- (void) setHighlighted: (BOOL) v
{
	highlighted = v;
}
@end
