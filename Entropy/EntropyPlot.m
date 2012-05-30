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
#include "EntropyPlot.h"

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

  id entropy = filter;
  NSLog(@"OK1");
  NSMutableArray *points = [entropy savedEntropyPoints];
  NSLog (@"%@", [points description]);
  //if (points == nil)
  points = [entropy getEntropyPoints: [entropy variableName]];
  NSLog (@"%@", [points description]);
 
  //  if ([points count] < 3) { NSLog(@"RET"); return; }

  NSArray *lastPoint = [points lastObject];
  double maxGain = [[lastPoint objectAtIndex: 1] doubleValue];
  double maxDiv = [[lastPoint objectAtIndex: 2] doubleValue];
  double max = maxGain;
  if (maxDiv > maxGain) max = maxDiv;
  NSLog(@"OK2");

  NSEnumerator *en = [points objectEnumerator];
  NSArray *point1 = [en nextObject];
  NSArray *point2 = nil;
  NSPoint p1;
  NSPoint p2;

  while ((point2 = [en nextObject])) {

    NSLog (@"%@", [point2 description]);

    double param1 =  [[point1 objectAtIndex: 0] doubleValue];
    double gain1 = [[point1 objectAtIndex: 1] doubleValue];
    double div1 = [[point1 objectAtIndex: 2] doubleValue];

    double param2 =  [[point2 objectAtIndex: 0] doubleValue];
    double gain2 = [[point2 objectAtIndex: 1] doubleValue];
    double div2 = [[point2 objectAtIndex: 2] doubleValue];

    [[NSColor blueColor] set];
    p1 = NSMakePoint (param1*b.size.width,b.size.height*gain1/max);
    p2 = NSMakePoint ((param1+(param2-param1)/2)*b.size.width,b.size.height*gain1/max);
    [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];

    p1 = NSMakePoint ((param1+(param2-param1)/2)*b.size.width,b.size.height*gain2/max);
    p2 = NSMakePoint (param2*b.size.width,b.size.height*gain2/max);
    [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];

    [[NSColor redColor] set];
    p1 = NSMakePoint (param1*b.size.width,b.size.height*div1/max);
    p2 = NSMakePoint ((param1+(param2-param1)/2)*b.size.width,b.size.height*div1/max);
    [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];

    p1 = NSMakePoint ((param1+(param2-param1)/2)*b.size.width,b.size.height*div2/max);
    p2 = NSMakePoint (param2*b.size.width,b.size.height*div2/max);
    [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];

    point1 = point2;
  }

  double param = [entropy parameter];
  [[NSColor blackColor] set];
  p1 = NSMakePoint (param*b.size.width,0);
  p2 = NSMakePoint (param*b.size.width,b.size.height);
  [NSBezierPath strokeLineFromPoint: p1 toPoint: p2];

}
@end
