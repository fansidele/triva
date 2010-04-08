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
- (void) setTimeIntervalFrom: (int) start to: (int) end;
@end

#endif
