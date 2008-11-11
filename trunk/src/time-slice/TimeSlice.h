#ifndef __TIMESLICE_H
#define __TIMESLICE_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "Treemap.h"

@interface TimeSlice  : PajeFilter
{
	NSDate *sliceStartTime;
	NSDate *sliceEndTime;

	Treemap *treemap;
}
- (void) setSliceStartTime: (NSDate *) time;
- (void) setSliceEndTime: (NSDate *) time;
- (void) timeSliceAt: (id) instance 
	      ofType: (id) type
	    withNode: (Treemap *) node;
- (Treemap *) pajeHierarchy: (id) instance parent:(Treemap *) parent;
- (Treemap *) treemapWithWidth: (int) width andHeight: (int) height;
- (NSString *) descriptionForNode: (Treemap *) node;
@end

#endif
