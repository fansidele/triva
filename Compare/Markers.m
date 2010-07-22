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
#include "Markers.h"

@implementation Markers
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  markers = [[NSMutableDictionary alloc] init];
  timeline = nil;
  return self;
}

- (void) dealloc
{
  [markers release];
  [super dealloc];
}

- (void) setTimeline: (Timeline*) t
{
  timeline = t;
}

- (void) clean
{
  [markers removeAllObjects];
}

- (void) add: (NSDictionary*) d
{
  [markers addEntriesFromDictionary: d];
}

- (void) drawRect: (NSRect) r
{
  NSEnumerator *en = [markers keyEnumerator];
  NSString *markerName;
  while  ((markerName = [en nextObject])){
    double time = [[[markers objectForKey: markerName] description]doubleValue];
    double position = [timeline timeToPixel: time];

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter: NSMakePoint(position,20)
                                     radius: 5
                                 startAngle: 0
                                   endAngle: 360];
    [path moveToPoint: NSMakePoint(position,20)];
    [path lineToPoint: NSMakePoint (position,0)];
    [path stroke];
    [path fill];
    [markerName drawAtPoint: NSMakePoint (position, 30) withAttributes: nil];
  }
}

- (BOOL) isFlipped
{
  return YES;
}

- (void) mouseDown: (NSEvent*) event
{
}

- (void) mouseDragged: (NSEvent*) event
{
}

- (void) mouseEntered: (NSEvent*) event
{
}

- (void) mouseExited: (NSEvent*) event
{
}
@end
