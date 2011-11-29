#ifndef __TIMESLICEGRAPH_H_
#define __TIMESLICEGRAPH_H_
#include <Foundation/Foundation.h>
#include "TimeSliceTree.h"

@interface TimeSliceGraph : TimeSliceTree
- (void) merge: (TimeSliceGraph *) other;
@end

#endif
