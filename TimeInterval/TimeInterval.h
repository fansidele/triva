/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef __TIMEINTERVAL_H
#define __TIMEINTERVAL_H
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include "../Triva/TrivaFilter.h"
#include "../Triva/TrivaWindow.h"
#include "SliceView.h"

@interface TimeInterval  : TrivaFilter
{
  IBOutlet id traceEndTimeLabel;
  IBOutlet id sliceView;
  IBOutlet id sliceWindowView;
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
  IBOutlet id forwardOnChange;
  TrivaWindow *window;
  id sliceWindow;

  double selStart;
  double selEnd;

  NSTimer *timer;

  BOOL hideWindow;
}
- (void) setTimeIntervalFrom: (double) start to: (double) end;
- (void) updateLabels;
- (void) apply;
- (void) animate;

- (void) apply: (id)sender;
- (void) play: (id)sender;
- (void) forwardSliderChanged: (id)sender;
- (void) forwardLabelChanged: (id) sender;
- (void) frequencySliderChanged: (id)sender;
- (void) frequencyLabelChanged: (id) sender;
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

- (void) switchSliceWindowVisibility;
- (void) updateViews;
@end

#endif
