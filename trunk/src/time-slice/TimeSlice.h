#ifndef __TIMESLICE_H
#define __TIMESLICE_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "TreeValue.h"

@interface TimeSlice  : PajeFilter
{
	NSDate *sliceStartTime;
	NSDate *sliceEndTime;
}
- (TreeValue *) pajeHierarchy: (id) instance parent:(TreeValue *) parent;
@end

#endif
