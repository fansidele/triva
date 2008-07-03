#ifndef __TRIVA_TREEMAP_H
#define __TRIVA_TREEMAP_H
#include <Foundation/Foundation.h>
#include <gvc.h>

@interface TrivaTreemap : NSObject
{
        NSString *name;
	NSString *type;
        float value;

	float width, height;
	float x, y;
	float depth;

	NSMutableArray *children;

	TrivaTreemap *parent;

	/* Category Graphviz: to render containers insider a leaf node */
	int nContainers, next;
	graph_t *g;
	GVC_t *gvc;
	float maxW, maxH;
}
+ (id) treemapWithDictionary: (id) tree;
- (id) initWithDictionary: (id) tree;
- (id) initWithString: (id) tree;
- (float) value;
- (float) width;
- (float) height;
- (float) x;
- (float) y;
- (float) depth;
- (void) setWidth: (float) w;
- (void) setHeight: (float) h;
- (void) setX: (float) xp;
- (void) setY: (float) yp;
- (void) setDepth: (float) d;
- (NSString *) name;
- (NSString *) type;
- (NSArray *) children;
- (void) setParent: (TrivaTreemap *) p;
- (void) reorder;

//Change Methods
- (void) incrementValue;
- (void) decrementValue;
- (void) recursiveResetValue;
- (void) resetValue;

//Methods to update values (after changing leaf's values)
- (void) recalculateValuesBottomUp;

//Search Methods
- (id) searchWithPartialName: (NSString *) partialName;
@end

@interface TrivaTreemap (Graphviz)
- (void) initializeGraphvizCategory;
- (void) recursiveResetNumberOfContainers;
- (void) resetNumberOfContainers;
- (void) incrementNumberOfContainers;
- (void) decrementNumberOfContainers;
- (NSPoint) nextLocation;
- (void) calculateMaxWandH;
@end

#endif
