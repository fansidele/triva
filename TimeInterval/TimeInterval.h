#ifndef __TIMEINTERVAL_H
#define __TIMEINTERVAL_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "TimeIntervalWindow.h"
#include <wx/timer.h>

#define TRIVA_TI 1000

static wxTimer timer;

@interface TimeInterval  : PajeFilter
{
	NSDate *selectionStartTime;
	NSDate *selectionEndTime;

	BOOL enable;
	BOOL animationIsRunning;
	double frequency, forward;
}
/* callbacks */
- (void) animationSliderChanged;
- (void) sliderChanged;
- (void) apply;
- (BOOL) play;
- (BOOL) pause;
- (void) animate;

/* other methods */
- (void) updateLabels;
- (void) setTimeIntervalFrom: (double) start to: (double) end;
- (double) traceTimeForSliderPosition: (int) position withSize: (double) size;
@end

#endif
