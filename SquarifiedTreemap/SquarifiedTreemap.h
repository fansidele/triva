#ifndef __SQUATREEMAP_H
#define __SQUATREEMAP_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "SquarifiedTreemap/Treemap.h"
#include "TimeSliceAggregation/TimeSliceTree.h"

@interface SquarifiedTreemap  : PajeFilter
{
	TimeSliceTree *timeSliceTree;
	Treemap *currentTreemap;
}
- (Treemap *) treemapWithWidth: (int) width
                     andHeight: (int) height
                      andDepth: (int) depth
                     andValues: (NSSet *) values;
@end

#endif
