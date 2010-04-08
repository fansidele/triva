#ifndef __TREEMAP_H_
#define __TREEMAP_H_
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Triva/Tree.h>
#include <Triva/TimeSliceTree.h>

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
	NSColor *color; //the color for this node
	NSMutableArray *aggregatedChildren;
	BOOL highlighted;
}
- (void) setValue: (float) v;
- (float) val;
- (TreemapRect *) treemapRect;
- (void) setTreemapRect: (TreemapRect *)r;
- (void) setColor: (NSColor *) c;
- (NSColor *) color;
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
- (Treemap *) searchWith: (NSPoint) point
			limitToDepth: (int) d
			andSelectedValues: (NSSet *) values;

- (NSComparisonResult) compareValue: (Treemap *) other;

/* creating the tree */
- (Treemap *) createTreeWithTimeSliceTree: (TimeSliceTree *) orig
		withValues: (NSSet *) values;

/* highlight methods */
- (BOOL) highlighted;
- (void) setHighlighted: (BOOL) v;
@end

#endif
