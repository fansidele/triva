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
#include "Marker.h"

@implementation Marker
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  timeline = nil;
  highlighted = NO;
  return self;
}

- (void) setTimeline: (Timeline*) t
{
  timeline = t;
}

- (void) drawRect: (NSRect) r
{
  {
    static int tag = 0;
    [self removeTrackingRect: tag];
    tag = [self addTrackingRect: [self bounds] owner: self userData: nil assumeInside: NO];
  }

  NSAffineTransform *trans = [NSAffineTransform transform];
  [trans rotateByDegrees: 90];
  [trans concat];
  if (highlighted){
    double time = [timeline pixelToTime:
                      [self convertPoint:NSMakePoint(0,0) toView:nil].x];
    [[NSString stringWithFormat: @"%f", time]
            drawAtPoint: NSMakePoint(30,-r.size.width)
         withAttributes: nil];
  }
  [trans invert];
  [trans concat];

  if (highlighted){
    [[NSColor redColor] set];
  }else{
    [[NSColor blueColor] set];
  }
}

- (void) mouseDown: (NSEvent*) event
{
  NSPoint p = [self convertPoint:[event locationInWindow] toView:self];
  offset = [self frame].origin.x - p.x;
}

- (void) mouseDragged: (NSEvent*) event
{
  NSPoint p = [self convertPoint:[event locationInWindow] toView:self];
  [self setFrameOrigin: NSMakePoint(p.x + offset, [self frame].origin.y)];
  [[self superview] setNeedsDisplay: YES];
}

- (double) position //return in pixels on superview coordinates
{
  //depends on the position of the marker drawing
  return [self frame].origin.x + 10; 
}

- (void) mouseEntered: (NSEvent*) event
{
  highlighted = YES;
  [self setNeedsDisplay: YES];
}

- (void) mouseExited: (NSEvent*) event
{
  highlighted = NO;
  [self setNeedsDisplay: YES];
}
@end

@implementation SliceStartMarker
- (void) drawRect: (NSRect) r
{
  [super drawRect: r];
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint: NSMakePoint (10, 30)];
  [path lineToPoint: NSMakePoint (20, 20)];
  [path lineToPoint: NSMakePoint (10, 10)];
  [path lineToPoint: NSMakePoint (10, 30)];
  [path lineToPoint: NSMakePoint (10, 0)];
  [path stroke];
  [path fill];
}

- (void) mouseUp: (NSEvent*) event
{
  [timeline sliceStartChanged];
}
@end

@implementation SliceEndMarker
- (void) drawRect: (NSRect) r
{
  [super drawRect: r];
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path moveToPoint: NSMakePoint (10, 30)];
  [path lineToPoint: NSMakePoint (0, 20)];
  [path lineToPoint: NSMakePoint (10, 10)];
  [path lineToPoint: NSMakePoint (10, 30)];
  [path lineToPoint: NSMakePoint (10, 0)];
  [path stroke];
  [path fill];
}

- (void) mouseUp: (NSEvent*) event
{
  [timeline sliceEndChanged];
}
@end

@implementation NormalMarker
- (void) drawRect: (NSRect) r
{
  [super drawRect: r];
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path appendBezierPathWithArcWithCenter: NSMakePoint(10,20)
                              radius: 5 startAngle: 0 endAngle: 360];
  [path moveToPoint: NSMakePoint(10,20)];
  [path lineToPoint: NSMakePoint (10,0)];
  [path stroke];
  [path fill];
}

- (BOOL) isFlipped
{
  return YES;
}

- (void) mouseDragged: (NSEvent*) event
{}
- (void) mouseDown: (NSEvent*) event
{}
@end
