#ifndef __TRIVA_TREEMAP_SQUARIFIED_H
#define __TRIVA_TREEMAP_SQUARIFIED_H
#include <Foundation/Foundation.h>
#include <math.h>
#include "TrivaTreemap.h"

@interface TrivaTreemapSquarified : TrivaTreemap
{
}
+ (id) treemapWithDictionary: (id) tree;
- (void) calculateWithWidth: (float) w height: (float) h;
- (void) calculateWithWidth: (float) W
              height: (float) H
              factor: (float) factor
		depth: (float) d;
@end

#endif
