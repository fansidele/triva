#ifndef __TIMESLICE_H
#define __TIMESLICE_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "Tree.h"

@interface TimeSlice  : PajeFilter
{
	NSDate *sliceStartTime;
	NSDate *sliceEndTime;
}
- (Tree *) pajeHierarchy: (id) instance parent:(Tree *) parent;
@end

#endif
