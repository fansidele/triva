#ifndef __SQUATREEMAP_H
#define __SQUATREEMAP_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "SquarifiedTreemap/Treemap.h"
#include "TimeSliceAggregation/TimeSliceTree.h"

@interface SquarifiedTreemap  : PajeFilter
{
	Treemap *currentTreemap;
}
- (Treemap *) defineTreemapWith: (TimeSliceTree *) tree;
- (Treemap *) treemapWithWidth: (int) width
                     andHeight: (int) height
                      andDepth: (int) depth
                     andValues: (NSSet *) values;
@end

#endif
