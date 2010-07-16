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
  return self;
}

- (void) setTimeline: (Timeline*) t
{
  timeline = t;
}

- (void) drawRect: (NSRect) r
{
  r = [self bounds];

  [[NSColor blueColor] set];
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path appendBezierPathWithArcWithCenter:
            NSMakePoint (r.size.width/2, 10)
                            radius: 5 startAngle: 270 endAngle: 269];
  [path lineToPoint: NSMakePoint (r.size.width/2, 0)];
  [path stroke];
  [path fill];

  NSAffineTransform *trans = [NSAffineTransform transform];
  [trans rotateByDegrees: 90];
  [trans concat];

  double time = [timeline pixelToTime:
                      [self convertPoint:NSMakePoint(0,0) toView:nil].x];
  [[NSString stringWithFormat: @"%f", time]
            drawAtPoint: NSMakePoint(15,-r.size.width)
         withAttributes: nil];
  [trans invert];
  [trans concat];
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
@end

@implementation SliceStartMarker
- (void) mouseUp: (NSEvent*) event
{
  [timeline sliceStartChanged];
}
@end

@implementation SliceEndMarker
- (void) mouseUp: (NSEvent*) event
{
  [timeline sliceEndChanged];
}
@end
