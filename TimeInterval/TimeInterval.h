#ifndef __TIMEINTERVAL_H
#define __TIMEINTERVAL_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "SliceView.h"

@interface TimeInterval  : PajeFilter
{
  IBOutlet id traceEndTimeLabel;
  IBOutlet id sliceView;
  IBOutlet id traceStartTimeLabel;
  IBOutlet id forwardLabel;
  IBOutlet id frequencyLabel;
  IBOutlet id playButton;
  IBOutlet id forwardSlider;
  IBOutlet id frequencySlider;
  IBOutlet id applyButton;
  IBOutlet id sizeSlider;
  IBOutlet id startSlider;
  IBOutlet id timeSelectionSize;
  IBOutlet id timeSelectionStart;
  IBOutlet id updateOnChange;

  double selStart;
  double selEnd;

  NSTimer *timer;
}
- (void) setTimeIntervalFrom: (double) start to: (double) end;
- (void) updateLabels;
- (void) apply;
- (void) animate;

- (void) apply: (id)sender;
- (void) play: (id)sender;
- (void) forwardSliderChanged: (id)sender;
- (void) frequencySliderChanged: (id)sender;
- (void) sliceSliderChanged: (id)sender;

/*
{

	BOOL enable;
	BOOL animationIsRunning;
	double frequency, forward;
}
// callbacks 
- (void) animationSliderChanged;
- (void) sliderChanged;
- (void) preciseSliceEntered;
- (void) apply;
- (BOOL) play;
- (BOOL) pause;
- (void) animate;

// other methods 
- (void) setTimeIntervalFrom: (double) start to: (double) end;
- (double) traceTimeForSliderPosition: (int) position withSize: (double) size;
*/
@end

#endif
