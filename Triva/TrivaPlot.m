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
                withName: (NSString*) n
              forObject: (TrivaGraphNode*) obj
        withDifferences: (NSDictionary*) differences
              withValues: (NSDictionary*) timeSliceValues
              andProvider: (TrivaFilter*) prov
{
  self = [super initWithFilter: prov andConfiguration: conf
                      andSpace: NO andName: n andObject: obj];
  //get scale for this composition
  NSString *scaleconf = [configuration objectForKey: @"scale"];
  if ([scaleconf isEqualToString: @"global"]){
    scale = Global;
  }else if ([scaleconf isEqualToString: @"local"]){
    scale = Local;
  }else if ([scaleconf isEqualToString: @"convergence"]){
    scale = Convergence;
  }else if ([scaleconf isEqualToString: @"arnaud"]){
    scale = Arnaud;
  }else{
    scale = Global;
  }

  //get only the first value (notice the "break" inside the while)
  NSEnumerator *en2 = [[configuration objectForKey: @"values"]objectEnumerator];
  while ((var = [en2 nextObject])){
    break;
  }
  if (!var){
    return nil;
  }

  //define min,max only once when scale is local, global or arnaud
  vmax = [filter maxOfVariable: var
                     withScale: scale
                      ofObject: [node name]
                      withType: [(TrivaGraphNode*)node type]];
  vmin = [filter maxOfVariable: var
                     withScale: scale
                      ofObject: [node name]
                      withType: [(TrivaGraphNode*)node type]];
  double vdelta = .1*(vmax-vmin);
  vmax += vdelta;
  vmin -= vdelta;
  valueSize = vmax - vmin;
  return self;
}

- (BOOL) redefineLayoutWithValues: (NSDictionary*) timeSliceValues
{
  //consider only the time slice
  NSDate *start = [filter selectionStartTime];
  NSDate *end = [filter selectionEndTime];

  tmin = [start timeIntervalSinceReferenceDate];
  tmax = [end timeIntervalSinceReferenceDate];
  sliceSize = tmax - tmin;

  //define min, max every time when scale is convergence
  if (scale == Convergence) {
    vmax = [filter maxOfVariable: var
                     withScale: scale
                      ofObject: [node name]
                      withType: [(TrivaGraphNode*)node type]];
    vmin = [filter maxOfVariable: var
                     withScale: scale
                      ofObject: [node name]
                      withType: [(TrivaGraphNode*)node type]];
    valueSize = vmax - vmin;
  }

  //transform to paje terminology
  PajeEntityType *varType = [filter entityTypeWithName: var];
  PajeEntityType *containerType = [filter entityTypeWithName: [node type]];
  PajeContainer *container = [filter containerWithName: [node name]
                                                type: containerType];

  //get the data
  NSEnumerator *en = [filter enumeratorOfEntitiesTyped: varType
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
  return NO;
}

- (void) refreshWithinRect: (NSRect) rect
{
  //use only the origin (size from rect is invalid - 0,0)
  bb = NSMakeRect (rect.origin.x,
                   rect.origin.y,
                   PLOT_WIDTH,
                   PLOT_HEIGHT);
}

- (BOOL) draw
{
  //update tmin, tmax
  NSDate *start = [filter selectionStartTime];
  NSDate *end = [filter selectionEndTime];
  tmin = [start timeIntervalSinceReferenceDate];
  tmax = [end timeIntervalSinceReferenceDate];

  if (1||[node highlighted]){

    //update vmax, vmin if scale = convergence
    if (scale == Convergence){
      vmax = [filter maxOfVariable: var
                     withScale: scale
                      ofObject: [node name]
                      withType: [(TrivaGraphNode*)node type]];
      vmin = [filter maxOfVariable: var
                     withScale: scale
                      ofObject: [node name]
                      withType: [(TrivaGraphNode*)node type]];
      valueSize = vmax - vmin;
    }

    //draw a rectangle
    [[NSColor blackColor] set];
    [NSBezierPath strokeRect: bb];
    //draw the name of the variable
    [name drawAtPoint: NSMakePoint (bb.origin.x, bb.origin.y + bb.size.height)
        withAttributes: nil];

    //getting the color
    [[filter colorForEntityType:
      [filter entityTypeWithName: var]] set];


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
      double value = ([[ent value] doubleValue] - vmin) / valueSize * PLOT_HEIGHT;
      [path lineToPoint: NSMakePoint (te, value)];
      [path lineToPoint: NSMakePoint (ts, value)];
      lastts = ts;
    }
    [path lineToPoint: NSMakePoint (lastts,0)];
    [path lineToPoint: NSMakePoint (PLOT_WIDTH,0)];

    NSAffineTransform *t = [NSAffineTransform transform];
    [t translateXBy: bb.origin.x yBy: bb.origin.y];
    [t concat];
    [path stroke];
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
