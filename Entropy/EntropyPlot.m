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
#include <AppKit/AppKit.h>
#include "EntropyPlot.h"
#include "Entropy.h"

@implementation EntropyPlot
- (void) setFilter: (id) f
{
  filter = f;
}

- (void) drawRect: (NSRect) rect
{
  NSRect b = [self bounds];

  [[NSColor lightGrayColor] set];
  NSRectFill(b);
  [NSBezierPath strokeRect: b];

  NSString *variableName = @"IDLE";

  Entropy *entropy = [[Entropy alloc] init];
  NSArray *points = [entropy getEntropyPoints: variableName];
  [entropy release];

  NSArray *lastPoint = [points lastObject];
  double maxGain = [[lastPoint objectAtIndex: 1] doubleValue];
  double maxDiv = [[lastPoint objectAtIndex: 2] doubleValue];

  NSEnumerator *en = [points objectEnumerator];
  NSArray *point1 = [en nextObject];
  NSArray *point2 = nil;
  while ((point2 = [en nextObject])) {

    double param1 =  [[point1 objectAtIndex: 0] doubleValue];
    double gain1 = [[point1 objectAtIndex: 1] doubleValue];
    double div1 = [[point1 objectAtIndex: 2] doubleValue];

    double param2 =  [[point2 objectAtIndex: 0] doubleValue];
    double gain2 = [[point2 objectAtIndex: 1] doubleValue];
    double div2 = [[point2 objectAtIndex: 2] doubleValue];

    
    [[NSColor blueColor] set];
    NSPoint p1 = NSMakePoint (param1,b.size.height*(1-gain1/maxGain));
    NSPoint p2 = NSMakePoint (param1+(param2-param1)/2,b.size.height*(1-gain1/maxGain));
    [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];

    p1 = NSMakePoint (param1+(param2-param1)/2,b.size.height*(1-gain2/maxGain));
    p2 = NSMakePoint (param2,b.size.height*(1-gain2/maxGain));
    [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];

    [[NSColor redColor] set];
    p1 = NSMakePoint (param1,b.size.height*(1-div1/maxDiv));
    p2 = NSMakePoint (param1+(param2-param1)/2,b.size.height*(1-div1/maxDiv));
    [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];

    p1 = NSMakePoint (param1+(param2-param1)/2,b.size.height*(1-div2/maxDiv));
    p2 = NSMakePoint (param2,b.size.height*(1-div2/maxDiv));
    [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];
  }
}
@end
