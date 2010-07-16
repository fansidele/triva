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
#include "Timeline.h"

#include <float.h>
#include <math.h>

@implementation Timeline
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

  //creating Slice Markers
  sliceStartMarker = [[SliceStartMarker alloc] initWithFrame: frame];
  sliceEndMarker = [[SliceEndMarker alloc] initWithFrame: frame];
  [sliceStartMarker setTimeline: self];
  [sliceEndMarker setTimeline: self];
  [self addSubview: sliceStartMarker];
  [self addSubview: sliceEndMarker];
  return self;
}

- (void) resizeSubviewsWithOldSize: (NSSize) size
{
  NSRect frame = [self frame];

  double selStart = [[[filter selectionStartTime] description] doubleValue];
  NSRect startFrame = NSMakeRect ([self timeToPixel: selStart]-10,
                                  frame.size.height/2,     //middle
                                  20,                      //20 pixels-width
                                  frame.size.height/2);   //50% of my height
  [sliceStartMarker setFrame: startFrame];

  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  NSRect endFrame = NSMakeRect ([self timeToPixel: selEnd]-10,
                                frame.size.height/2,
                                20,
                                frame.size.height/2);
  [sliceEndMarker setFrame: endFrame];
}

- (void) setFilter: (id) f
{
  filter = f;
}

- (void) setController: (id) c
{
  controller = c;
}

- (void) updateRatio
{
  NSRect bb = [self bounds];
  ratio = (bb.size.width - 10)/[controller largestEndTime];
}

- (void) drawRect: (NSRect) r
{
  NSRect bb = [self bounds];
  [self updateRatio];

  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  double filterEndTime = [[[filter endTime] description] doubleValue];

  //drawing the timeline
  NSBezierPath *timeline = [NSBezierPath bezierPath];
  [timeline moveToPoint: NSMakePoint (bb.origin.x + 5,
                                      bb.size.height / 2)];
  [timeline relativeMoveToPoint: NSMakePoint (0, 5)];
  [timeline relativeLineToPoint: NSMakePoint (0, -10)];
  [timeline relativeMoveToPoint: NSMakePoint (0, 5)];
  [timeline lineToPoint: NSMakePoint ([self timeToPixel: filterEndTime], 
                                      bb.size.height / 2)];
  [timeline relativeMoveToPoint: NSMakePoint (0, 5)];
  [timeline relativeLineToPoint: NSMakePoint (0, -10)];
  [timeline relativeMoveToPoint: NSMakePoint (0, 5)];
  [[NSColor blackColor] set];
  [timeline stroke];

  //drawing the selected time slice
  NSBezierPath *timeslice = [NSBezierPath bezierPath];
  [timeslice moveToPoint: NSMakePoint ([self timeToPixel: selStart],
                                       bb.size.height/2 - 2)];
  [timeslice lineToPoint: NSMakePoint ([self timeToPixel: selEnd],
                                       bb.size.height/2 - 2)];
  [timeslice relativeLineToPoint: NSMakePoint (0, 4)];
  [timeslice lineToPoint: NSMakePoint ([self timeToPixel: selStart],
                                       bb.size.height/2 + 2)];
  [timeslice relativeLineToPoint: NSMakePoint (0, -4)];
  [[NSColor lightGrayColor] set];
  [timeslice fill];
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void) sliceStartChanged
{
  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  double start = [self pixelToTime: [sliceStartMarker position]];
  [filter setTimeIntervalFrom: start to: selEnd];
}
- (void) sliceEndChanged
{
  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double end = [self pixelToTime: [sliceEndMarker position]];
  [filter setTimeIntervalFrom: selStart to: end];
}

- (double) pixelToTime: (double) pixel
{
  return (pixel - 5) / ratio;
}

- (double) timeToPixel: (double) time
{
  return 5 + (time * ratio);
}
@end
