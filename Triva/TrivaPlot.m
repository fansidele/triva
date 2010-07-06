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
#include "TrivaPlot.h"

#define PLOT_WIDTH 42
#define PLOT_HEIGHT 30

@implementation TrivaPlot
- (id) initWithConfiguration: (NSDictionary*) conf
              forObject: (TrivaGraphNode*) obj
              withValues: (NSDictionary*) timeSliceValues
              andProvider: (TrivaFilter*) prov
{
  self = [super init];
  provider = prov;

  //saving node
  node = obj;

  //plot is not drawn inside the visual object
  needSpace = NO;

  //get only the first value (notice the "break" inside the while)
  NSEnumerator *en2 = [[conf objectForKey: @"values"] objectEnumerator];
  id var;
  while ((var = [en2 nextObject])){
    break;
  }
  if (!var){
    return nil;
  }

  //consider only the time slice
  NSDate *start = [provider selectionStartTime];
  NSDate *end = [provider selectionEndTime];

  tmin = [start timeIntervalSinceReferenceDate];
  tmax = [end timeIntervalSinceReferenceDate];
  sliceSize = tmax - tmin;

  //transform to paje terminology
  PajeEntityType *varType = [provider entityTypeWithName: var];
  PajeEntityType *containerType = [provider entityTypeWithName: [obj type]];
  PajeContainer *container = [provider containerWithName: [obj name]
                                                type: containerType];

  //get max min value for the type
  vmax = [provider maxValueForEntityType: varType];
  vmin = [provider minValueForEntityType: varType];
  valueSize = vmax - vmin;

  //get the data
  NSEnumerator *en = [provider enumeratorOfEntitiesTyped: varType
                                           inContainer: container
                                              fromTime: start
                                                toTime: end
                                           minDuration: 0];
  objects = [en allObjects];
  [objects retain];
/*
  NSLog (@"%@ (%@) - %d", var, [obj name], [[en allObjects] count]);
  return self;
  id ent;
  while ((ent = [en nextObject])){
    double val = [[ent value] doubleValue];
    NSLog (@"%@ -> %f", var, val);
  }
*/
  return self;
}

- (void) refreshWithinRect: (NSRect) rect
{
  bb = NSMakeRect (rect.origin.x + rect.size.width + 1,
                   rect.origin.y,
                   PLOT_WIDTH,
                   PLOT_HEIGHT);
}

- (BOOL) draw
{
  //update tmin, tmax
  NSDate *start = [provider selectionStartTime];
  NSDate *end = [provider selectionEndTime];
  tmin = [start timeIntervalSinceReferenceDate];
  tmax = [end timeIntervalSinceReferenceDate];

  if (1||[node highlighted]){
    //draw a rectangle
    [[NSColor blackColor] set];
    [NSBezierPath strokeRect: bb];

    [[NSColor grayColor] set];
    //draw the points in the inverse sense (paje gives us the objects that way
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: NSMakePoint (PLOT_WIDTH,0)];
    id ent;
    NSEnumerator *en = [objects objectEnumerator];
    double lastts = 0;
    while ((ent = [en nextObject])){
      double ts = [[ent startTime] timeIntervalSinceReferenceDate];
      if (ts < tmin) ts = tmin;
      ts = (ts - tmin) / sliceSize * PLOT_WIDTH;
      double te = [[ent endTime] timeIntervalSinceReferenceDate];
      if (te > tmax) te = tmax;
      te = (te - tmin) / sliceSize * PLOT_WIDTH;

      if (te == ts) continue;
      double value = [[ent value] doubleValue] / valueSize * PLOT_HEIGHT;
      [path lineToPoint: NSMakePoint (te, value)];
      [path lineToPoint: NSMakePoint (ts, value)];
      lastts = ts;
    }
    [path lineToPoint: NSMakePoint (lastts,0)];
    [path lineToPoint: NSMakePoint (PLOT_WIDTH,0)];

    NSAffineTransform *t = [NSAffineTransform transform];
    [t translateXBy: bb.origin.x yBy: bb.origin.y];
    [t concat];
    [path fill];
    [t invert];
    [t concat];
  }
  return YES;
}

- (void) dealloc
{
  [objects release];
  [super dealloc];
}
@end