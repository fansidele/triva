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
  NSRect startFrame = NSMakeRect ((selStart * ratio)-10, //selStart position
                                  frame.size.height/2,     //middle
                                  20,                      //20 pixels-width
                                  frame.size.height/2);   //50% of my height
  [sliceStartMarker setFrame: startFrame];


  double traceEnd = [[[filter endTime] description] doubleValue];
  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  double xpos;
  if (selEnd == traceEnd){
    xpos = frame.size.width - 20;
  }else{
    xpos = (selEnd * ratio) - 10;
  }
  NSRect endFrame = NSMakeRect (xpos,
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

- (void) drawRect: (NSRect) r
{
  NSRect bb = [self bounds];
  ratio = bb.size.width/[controller largestEndTime];

  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  double filterEndTime = [[[filter endTime] description] doubleValue];

  //drawing the timeline
  NSRect t = NSMakeRect (bb.origin.x,
                         bb.origin.y + bb.size.height/2 - 1,
                         filterEndTime * ratio,
                         2);
  [[NSColor blackColor] set];
  [NSBezierPath fillRect: t];

  //drawing the selected time slice
  NSRect s = NSMakeRect (selStart * ratio,
                         bb.origin.y + bb.size.height/2 - 2,
                         (selEnd * ratio) - (selStart * ratio),
                         4);
  [[NSColor lightGrayColor] set];
  [NSBezierPath fillRect: s];
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void) sliceStartChanged
{
  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  double start = ([sliceStartMarker frame].origin.x+10) / ratio;
  [filter setTimeIntervalFrom: start to: selEnd];
}
- (void) sliceEndChanged
{
  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double end = ([sliceEndMarker frame].origin.x+10) / ratio;
  [filter setTimeIntervalFrom: selStart to: end];
}

- (double) pixelToTime: (double) pixel
{
  return pixel / ratio;
}

- (double) timeToPixel: (double) time
{
  return time * ratio;
}
@end
