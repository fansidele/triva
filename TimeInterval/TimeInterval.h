#ifndef __TIMEINTERVAL_H
#define __TIMEINTERVAL_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "TimeIntervalWindow.h"

#define TRIVA_TI 1000

@interface TimeInterval  : PajeFilter
{
	NSDate *selectionStartTime;
	NSDate *selectionEndTime;

	BOOL enable;
}
- (double) traceTimeForSliderPosition: (int) position;
- (void) setTimeIntervalFrom: (int) start to: (int) end;
- (BOOL) forwardSelectionTime: (double) seconds;
@end

#endif
