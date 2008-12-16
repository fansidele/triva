#ifndef __TIMESLICE_H
#define __TIMESLICE_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "Treemap.h"
#include "TreeIntegrated.h"

@interface TimeSlice  : PajeFilter
{
	NSDate *sliceStartTime;
	NSDate *sliceEndTime;

	Treemap *treemap;

	/* Configuration */
	BOOL fillWithEmptyNodes;
	BOOL considerExclusiveDuration;
}
- (void) setSliceStartTime: (NSDate *) time;
- (void) setSliceEndTime: (NSDate *) time;
- (void) timeSliceAt: (id) instance 
	      ofType: (id) type
	    withNode: (Treemap *) node;
- (Treemap *) pajeHierarchy: (id) instance parent:(Treemap *) parent;
- (void) limitTreemap: (Treemap *) tree toDepth: (int) depth;
- (Treemap *) treemapWithWidth: (int) width
		     andHeight: (int) height
		      andDepth: (int) depth;
- (NSString *) descriptionForNode: (Treemap *) node;
@end

#endif
