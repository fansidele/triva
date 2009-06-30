#ifndef __TREEMAP_H_
#define __TREEMAP_H_
#include <Foundation/Foundation.h>
#include "TreeValue.h"

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

@interface Treemap : TreeValue 
{
	TreemapRect *rect;

	NSMutableArray *aggregatedChildren; /* to limitTreemap method */

	id pajeEntity; /* the paje entity connected to this node */
}
- (TreemapRect *) rect;
- (void) setRect: (TreemapRect *)r;
- (void) setPajeEntity: (id) entity;
- (id) pajeEntity;

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

/* methods to be used by the TimeSlice.m's limitTreemap */
- (void) addAggregatedChild: (Treemap *) child;
- (void) removeAllAggregatedChildren;
- (NSArray *) aggregatedChildren;
@end

#endif
