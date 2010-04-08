#ifndef __TRIVA_TREEMAP_SQUARIFIED_H
#define __TRIVA_TREEMAP_SQUARIFIED_H
#include <Foundation/Foundation.h>
#include <math.h>
#include "TrivaTreemap.h"

@interface TrivaTreemapSquarified : TrivaTreemap
{
	float mainWidth;
	float mainHeight;
}
+ (id) treemapWithDictionary: (id) tree;
- (void) calculateWithWidth: (float) w height: (float) h;
- (void) calculateWithWidth: (float) W
              height: (float) H
              factor: (float) factor
		depth: (float) d;
- (void) recalculate;
- (void) setMainWidth: (float) mw; //set only for root node
- (void) setMainHeight: (float) mh; //set only for root node
@end

#endif
