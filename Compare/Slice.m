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
#include "Slice.h"

#define TIMESLICEHEIGHT 5

@implementation Slice
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  timeline = nil;
  timeSliceHighlighted = NO;
  timeSliceTrackingTag = -1;
  timeSliceRect = NSZeroRect;
  startHighlighted = NO;
  startTrackingTag = -1;
  endHighlighted = NO;
  endTrackingTag = -1;
  return self;
}

- (void) setTimeline: (Timeline*) t
{
  timeline = t;
}

- (void) drawRect: (NSRect) r
{
  NSBezierPath *path;

  if (startHighlighted){
    [[NSColor redColor] set];
  }else{
    [[NSColor blueColor] set];
  }

  path = [NSBezierPath bezierPath];
  [path moveToPoint: NSMakePoint (startPosition, 30)];
  [path lineToPoint: NSMakePoint (startPosition+10, 20)];
  [path lineToPoint: NSMakePoint (startPosition, 10)];
  [path lineToPoint: NSMakePoint (startPosition, 30)];
  [path lineToPoint: NSMakePoint (startPosition, 0)];
  [path stroke];
  [path fill];

  //drawing the time position of the start marker
  {
    double time = [timeline pixelToTime: startPosition];
    NSString *startMessage = [NSString stringWithFormat: @"%g", time];
    NSPoint point = NSMakePoint (startPosition, 30);
    [startMessage drawAtPoint: point withAttributes: nil];
  }

  if (endHighlighted){
    [[NSColor redColor] set];
  }else{
    [[NSColor blueColor] set];
  }

  path = [NSBezierPath bezierPath];
  [path moveToPoint: NSMakePoint (endPosition, 30)];
  [path lineToPoint: NSMakePoint (endPosition-10, 20)];
  [path lineToPoint: NSMakePoint (endPosition, 10)];
  [path lineToPoint: NSMakePoint (endPosition, 30)];
  [path lineToPoint: NSMakePoint (endPosition, 0)];
  [path stroke];
  [path fill];

  //drawing the time position of end marker
  {
    double time = [timeline pixelToTime: endPosition];
    NSString *endMessage = [NSString stringWithFormat: @"%g", time];
    NSPoint point = NSMakePoint (endPosition, 30);
    NSSize size = [endMessage sizeWithAttributes: nil];
 
    if ((endPosition+size.width) > [self bounds].size.width){
      point.x -= (endPosition+size.width) - [self bounds].size.width;
    }
    [endMessage drawAtPoint: point withAttributes: nil];
  }

  if (timeSliceHighlighted){
    [[NSColor redColor] set];
  }else{
    [[NSColor blueColor] set];
  }

  //drawing a visual representation of the time slice
  [NSBezierPath fillRect: timeSliceRect];
  {
    double time = [timeline pixelToTime: endPosition] -
                    [timeline pixelToTime: startPosition];
    NSString *sliceMessage = [NSString stringWithFormat: @"%g", time];
    NSSize size = [sliceMessage sizeWithAttributes: nil];
    NSPoint point;
    double tswidth = (endPosition-startPosition);
    if (tswidth-10 > size.width){
      point = NSMakePoint (startPosition + tswidth/2 - size.width/2,
                                                            TIMESLICEHEIGHT);
    }else{
      point = NSMakePoint (startPosition + tswidth/2 - size.width/2,
                                                            40);
    }
    [sliceMessage drawAtPoint: point withAttributes: nil];
  }
}

- (void) mouseDown: (NSEvent*) event
{
  if (startHighlighted){
    NSPoint p = [self convertPoint:[event locationInWindow] fromView: nil];
    offset = startPosition - p.x;
  }else if (endHighlighted){
    NSPoint p = [self convertPoint:[event locationInWindow] fromView: nil];
    offset = endPosition - p.x;
  }else if (timeSliceHighlighted){
    NSPoint p = [self convertPoint:[event locationInWindow] fromView: nil];
    offset = startPosition - p.x; //consider the beggining
  }else{
    [super mouseDown: event];
  }
}

- (void) mouseDragged: (NSEvent*) event
{
  if (startHighlighted){
    NSPoint p = [self convertPoint:[event locationInWindow] fromView: nil];
    [self setStartPosition: p.x + offset];
  }else if (endHighlighted){
    NSPoint p = [self convertPoint:[event locationInWindow] fromView: nil];
    [self setEndPosition: p.x + offset];
  }else if (timeSliceHighlighted){
    NSPoint p = [self convertPoint:[event locationInWindow] fromView: nil];
    double timeSliceSize = endPosition - startPosition;
    [self setStartPosition: p.x + offset];
    [self setEndPosition: p.x + offset + timeSliceSize];
  }else{
    [super mouseDragged: event];
  }
  [self setNeedsDisplay: YES];
}

- (void) mouseUp: (NSEvent*) event
{
  if (startHighlighted){
    [timeline sliceStartChanged];
  }else if (endHighlighted){
    [timeline sliceEndChanged];
  }else if (timeSliceHighlighted){
    [timeline sliceChanged];
  }
}

- (void) updateTimeSliceTrackingRect
{
  timeSliceRect = NSMakeRect (startPosition, 0,
                              endPosition-startPosition, TIMESLICEHEIGHT);
  timeSliceTrackingRect = timeSliceRect;
  timeSliceTrackingRect.origin.x += 20;
  timeSliceTrackingRect.size.width -= 40;
  timeSliceTrackingRect.size.height = [self bounds].size.height;

  [self removeTrackingRect: timeSliceTrackingTag];
  timeSliceTrackingTag = [self addTrackingRect: timeSliceTrackingRect
                                     owner: self
                                  userData: nil
                              assumeInside: NO];
}

- (void) setStartPosition: (double) p
{
  startPosition = p;

  NSRect trackingRect = NSMakeRect (startPosition-10, 0,
                                    20, [self bounds].size.height);

  [self removeTrackingRect: startTrackingTag];
  startTrackingTag = [self addTrackingRect: trackingRect
                                     owner: self
                                  userData: nil
                              assumeInside: NO];
  [self updateTimeSliceTrackingRect];
}

- (void) setEndPosition: (double) p
{
  endPosition = p;

  NSRect trackingRect = NSMakeRect (endPosition-10, 0,
                                    20, [self bounds].size.height);

  [self removeTrackingRect: endTrackingTag];
  endTrackingTag = [self addTrackingRect: trackingRect
                                     owner: self
                                  userData: nil
                              assumeInside: NO];
  [self updateTimeSliceTrackingRect];
}

- (double) startPosition
{
  return startPosition;
}

- (double) endPosition
{
  return endPosition;
}

- (void) mouseEntered: (NSEvent*) event
{
  if ([event trackingNumber] == startTrackingTag){
    if (endHighlighted == NO)
      startHighlighted = YES;
  }else if ([event trackingNumber] == endTrackingTag){
    if (startHighlighted == NO)
      endHighlighted = YES;
  }else if ([event trackingNumber] == timeSliceTrackingTag){
    if (startHighlighted == NO && endHighlighted == NO)
      timeSliceHighlighted = YES;
  }
  [self setNeedsDisplay: YES];
}

- (void) mouseExited: (NSEvent*) event
{
  startHighlighted = NO;
  endHighlighted = NO;
  timeSliceHighlighted = NO;
  [self setNeedsDisplay: YES];
}
@end
