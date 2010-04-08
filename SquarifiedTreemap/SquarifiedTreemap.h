#ifndef __SQUATREEMAP_H
#define __SQUATREEMAP_H
#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <Triva/TimeSliceTree.h>
#include "SquarifiedTreemap/Treemap.h"

@interface SquarifiedTreemap  : TrivaFilter
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
