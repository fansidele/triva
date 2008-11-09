#ifndef __TIMESLICE_H
#define __TIMESLICE_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "Treemap.h"

@interface TimeSlice  : PajeFilter
{
	NSDate *sliceStartTime;
	NSDate *sliceEndTime;
}
- (void) timeSliceAt: (id) instance 
	      ofType: (id) type
	    withNode: (Treemap *) node;
- (Treemap *) pajeHierarchy: (id) instance parent:(Treemap *) parent;
@end

#endif
