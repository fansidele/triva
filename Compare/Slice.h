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
#ifndef __Slice_h_
#define __Slice_h_

#include <AppKit/AppKit.h>

@class Timeline;

@interface Slice : NSView
{
  double offset; //for mouse dragging
  Timeline *timeline;

  BOOL timeSliceHighlighted;
  NSTrackingRectTag timeSliceTrackingTag;
  NSRect timeSliceRect;
  NSRect timeSliceTrackingRect;

  double startPosition;
  BOOL startHighlighted;
  NSTrackingRectTag startTrackingTag;

  double endPosition;
  BOOL endHighlighted;
  NSTrackingRectTag endTrackingTag;
}
- (void) setTimeline: (Timeline*) t;
- (void) setStartPosition: (double) p;
- (void) setEndPosition: (double) p;
- (double) startPosition;
- (double) endPosition;
@end

#include "Timeline.h"
#endif
