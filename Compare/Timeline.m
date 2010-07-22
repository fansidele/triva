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

#define BORDERGAP 30

@implementation Timeline
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];

  //creating Slice Markers
  slice = [[Slice alloc] initWithFrame: frame];
  markers = [[Markers alloc] initWithFrame: frame];
  [slice setTimeline: self];
  [markers setTimeline: self];
  [self addSubview: slice];
  [self addSubview: markers];
  return self;
}

- (void) updateMarkers
{
  //remove existing markers
  [markers clean];

  //adding them according to their presence on the filter
  PajeEntityType *type = [filter entityTypeWithName: 
                                [controller currentMarkerType]];
  PajeContainer *root = [filter rootInstance];
  
  NSEnumerator *en = [filter enumeratorOfEntitiesTyped: type
                                           inContainer: root
                                              fromTime: 0
                                                toTime: [filter endTime]
                                           minDuration: 0];
  id entity;
  NSMutableDictionary *d = [NSMutableDictionary dictionary];
  while ((entity = [en nextObject])){
    [d setObject: [entity startTime] forKey: [entity name]];
  }
  [markers add: d];
  [markers setNeedsDisplay: YES];
}

- (void) resizeSubviewsWithOldSize: (NSSize) size
{
  NSRect frame = [self frame];
  NSRect sliceRect = NSMakeRect (0, frame.size.height/2,
                                 frame.size.width, frame.size.height/2);
  [slice setFrame: sliceRect];
  [slice setNeedsDisplay: YES];

  NSRect markersRect = NSMakeRect (0,0, frame.size.width, frame.size.height/2);
  [markers setFrame: markersRect];
  [markers setNeedsDisplay: YES];

  [self timeSelectionChanged];
}

- (void) timeSelectionChanged
{
  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  [slice setStartPosition: [self timeToPixel: selStart]];
  [slice setEndPosition: [self timeToPixel: selEnd]];
  [slice setNeedsDisplay: YES];
}

- (id) filter
{
  return filter;
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
  ratio = (bb.size.width - BORDERGAP)/[controller largestEndTime];
}

- (void) drawRect: (NSRect) r
{
  NSRect bb = [self bounds];
  [self updateRatio];

  double filterEndTime = [[[filter endTime] description] doubleValue];

  //drawing the timeline
  NSBezierPath *timeline = [NSBezierPath bezierPath];
  [timeline moveToPoint: NSMakePoint (bb.origin.x + (BORDERGAP/2),
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

  //draw the name of the trace file for this timeline
  [[filter traceDescription] drawAtPoint: NSMakePoint(0,0)
                          withAttributes: nil];
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void) sliceStartChanged
{
  double start = [self pixelToTime: [slice startPosition]];
  [controller setStartTimeInterval: start ofFilter: filter];
}
- (void) sliceEndChanged
{
  double end = [self pixelToTime: [slice endPosition]];
  [controller setEndTimeInterval: end ofFilter: filter];
}

- (void) sliceChanged
{
  double start = [self pixelToTime: [slice startPosition]];
  double end = [self pixelToTime: [slice endPosition]];
  [controller setTimeIntervalStart: start end: end ofFilter: filter];
}

- (double) pixelToTime: (double) pixel
{
  return (pixel - (BORDERGAP/2)) / ratio;
}

- (double) timeToPixel: (double) time
{
  return (BORDERGAP/2) + (time * ratio);
}
@end
