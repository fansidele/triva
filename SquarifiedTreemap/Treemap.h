#ifndef __TREEMAP_H_
#define __TREEMAP_H_
#include <Foundation/Foundation.h>
#include "Tree.h"
#include "TimeSliceAggregation/TimeSliceTree.h"

@interface TreemapRect : NSObject
{
        float width;
        float height;
        float x;
        float y;
}
- (float) width;
- (float) height;
- (float) x;
- (float) y;
- (void) setWidth: (float) w;
- (void) setHeight: (float) h;
- (void) setX: (float) xis;
- (void) setY: (float) ipslon;
@end

@interface Treemap : Tree
{
	TreemapRect *rect;
	float value;
	id pajeEntity; /* the paje entity connected to this node */
	NSMutableArray *aggregatedChildren;
}
- (void) setValue: (float) v;
- (float) val;
- (TreemapRect *) treemapRect;
- (void) setTreemapRect: (TreemapRect *)r;
- (void) setPajeEntity: (id) entity;
- (id) pajeEntity;
- (NSArray *) aggregatedChildren;

/* squarified treemap methods */
- (double) worstf: (NSArray *) list
                withSmallerSize: (double) w
                withFactor: (double) factor;
- (TreemapRect *)layoutRow: (NSArray *) row
                withSmallerSize: (double) w
                withinRectangle: (TreemapRect *) r
                withFactor: (double) factor;
- (void) squarifyWithOrderedChildren: (NSMutableArray *) list
                andSmallerSize: (double) w
                andFactor: (double) factor;
- (void) calculateTreemapRecursiveWithFactor: (double) factor;
- (void) calculateTreemapWithWidth: (float) w andHeight: (float) h;

/* search-based methods */
- (Treemap *) searchWithX: (long) x
			andY: (long) y
			limitToDepth: (int) d;

- (NSComparisonResult) compareValue: (Treemap *) other;

/* creating the tree */
- (Treemap *) createTreeWithTimeSliceTree: (TimeSliceTree *) orig;
@end

#endif