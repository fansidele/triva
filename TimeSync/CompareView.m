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
/* All Rights reserved */

#include "CompareView.h"

@interface CompareView (Hidden)
- (void) updatePixelToTimeRatio;
- (double) pixelToTime: (double) pixel;
- (double) timeToPixel: (double) time;
- (void) updateRuler;
@end

@implementation CompareView
- (id) initWithFrame: (NSRect) r
{
  self = [super initWithFrame: r];
  largestTimestamp = -FLT_MAX;
  nTimeline = 0;
  pixelToTimeRatio = 0;
  mousePoint = NSZeroPoint;
  return self;
}

- (void) setController: (TimeSyncController*) cc
{
  controller = cc;
}

- (void) drawRect: (NSRect)r
{
  if (pixelToTimeRatio == 0){
    [self updatePixelToTimeRatio];
  }

  [[NSColor whiteColor] set];
  [NSBezierPath fillRect: [self bounds]];
  [[NSColor blackColor] set];

  //draw timelines
  //double width = [self bounds].size.width;
  double height = [self bounds].size.height;
  double verticalStep = height/nTimeline;
  double timelineVerticalPosition = verticalStep/2;

  //reset drag ops
  if (!draggingOperation){
    dragWhat = Nothing;
    dragFilter = nil;
  }

  //ad-hoc visual matching of markers
  [[NSColor lightGrayColor] set];
  NSMutableDictionary *dmarker = [[NSMutableDictionary alloc] init];
  {
  id filter;
  NSEnumerator *en = [[controller filters] objectEnumerator];
  while ((filter = [en nextObject])){
    //adding markers according to their presence on the filter
    PajeEntityType *type = [filter entityTypeWithName:
                                [controller currentMarkerType]];
    PajeContainer *root = [filter rootInstance];

    NSEnumerator *en = [filter enumeratorOfEntitiesTyped: type
                                           inContainer: root
                                              fromTime: 0
                                                toTime: 
                                 [NSDate distantFuture]
                                           minDuration: 0];
    id entity;
    while ((entity = [en nextObject])){
      NSMutableArray *ar = [dmarker objectForKey: [entity name]];
      if (ar == nil){
        ar = [[NSMutableArray alloc] init];
        [dmarker setObject: ar forKey: [entity name]];
        [ar release];
      }
      [ar addObject: [entity startTime]];
    }
  }
  en = [dmarker keyEnumerator];
  id marker;
  while ((marker = [en nextObject])){
    NSString *markerName = marker;
    NSArray *positions = [dmarker objectForKey: markerName];

    double timelineVerticalPosition = verticalStep/2;
    NSDate *pos;
    NSEnumerator *en2 = [positions objectEnumerator];

    NSPoint points[[positions count]]; //eca
    int i = 0;
    while ((pos = [en2 nextObject])){
      double t = [[pos description] doubleValue];
      points[i] = NSMakePoint ([self timeToPixel: t],timelineVerticalPosition);
      timelineVerticalPosition += verticalStep;
      i++;
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithPoints: points count: i];
    [path stroke];


  }
  [dmarker release];
  }
  


  id filter;
  NSEnumerator *en = [[controller filters] objectEnumerator];
  while ((filter = [en nextObject])){
    double endTime = [[[filter endTime] description] doubleValue];

    //draw the name of the trace
    [[[[filter traceDescription] pathComponents] lastObject]
                        drawAtPoint: NSMakePoint([self timeToPixel:0],timelineVerticalPosition+40)
                     withAttributes: nil];

    //draw the timeline
    NSBezierPath *timeline = [NSBezierPath bezierPath];
    [timeline moveToPoint: NSMakePoint ([self timeToPixel: 0], timelineVerticalPosition)];
    [timeline relativeLineToPoint: NSMakePoint ([self timeToPixel: endTime], 0)];
    [timeline stroke];

    //draw the start slice marker
    double sTime = [[[filter selectionStartTime] description] doubleValue];
    NSBezierPath *sMarker = [NSBezierPath bezierPath];
    [sMarker moveToPoint:
        NSMakePoint ([self timeToPixel: sTime], timelineVerticalPosition)];
    [sMarker relativeLineToPoint: NSMakePoint (0, 30)];
    [sMarker relativeLineToPoint: NSMakePoint (10, -10)];
    [sMarker relativeLineToPoint: NSMakePoint (-10, -10)];
    [sMarker stroke];
    if ([sMarker containsPoint: mousePoint]){
      [self drawText: [[filter selectionStartTime] description]
             atPoint: mousePoint];
      if (!draggingOperation){
        dragWhat = Start;
        dragFilter = filter;
      }
      [sMarker fill];
    }

    //draw the end slice marker
    double eTime = [[[filter selectionEndTime] description] doubleValue];
    NSBezierPath *eMarker = [NSBezierPath bezierPath];
    [eMarker moveToPoint:
        NSMakePoint ([self timeToPixel: eTime], timelineVerticalPosition)];
    [eMarker relativeLineToPoint: NSMakePoint (0, 30)];
    [eMarker relativeLineToPoint: NSMakePoint (-10, -10)];
    [eMarker relativeLineToPoint: NSMakePoint (10, -10)];
    [eMarker stroke];
    if ([eMarker containsPoint: mousePoint]){
      [self drawText: [[filter selectionEndTime] description]
             atPoint: mousePoint];
      if (!draggingOperation){
        dragWhat = End;
        dragFilter = filter;
      }
      [eMarker fill];
    }

    //draw the slice representation
    NSBezierPath *slice = [NSBezierPath bezierPath];
    [slice moveToPoint:
      NSMakePoint ([self timeToPixel: sTime], timelineVerticalPosition)];
    [slice relativeLineToPoint: NSMakePoint (0, 5)];
    [slice lineToPoint: NSMakePoint ([self timeToPixel:eTime],timelineVerticalPosition+5)];
    [slice relativeLineToPoint: NSMakePoint (0, -5)];
    [slice closePath];
    [slice stroke];
    [[NSColor grayColor] set];
    [slice fill];
    [[NSColor blackColor] set];
  
      

    //adding markers according to their presence on the filter
    PajeEntityType *type = [filter entityTypeWithName:
                                [controller currentMarkerType]];
    PajeContainer *root = [filter rootInstance];

    NSEnumerator *en = [filter enumeratorOfEntitiesTyped: type
                                           inContainer: root
                                              fromTime: 0
                                                toTime: 
                                 [NSDate distantFuture]
                                           minDuration: 0];
    id entity;
    while ((entity = [en nextObject])){
      double time = [[[entity startTime] description] doubleValue];
      NSBezierPath *marker = [NSBezierPath bezierPath];
      [marker moveToPoint:
        NSMakePoint ([self timeToPixel:time], timelineVerticalPosition)];
      [marker relativeLineToPoint:
        NSMakePoint (0, -30)];
      [marker appendBezierPathWithArcWithCenter:
            NSMakePoint([self timeToPixel: time],timelineVerticalPosition-30)
                              radius: 5 startAngle: 0 endAngle: 360];
      [marker lineToPoint: NSMakePoint ([self timeToPixel: time], timelineVerticalPosition-30)];
      [marker stroke];
      if ([marker containsPoint: mousePoint]){
        NSString *str = [NSString stringWithFormat: @"%@ [%@]",
            [entity name], [entity startTime]];
        [self drawText: str atPoint: mousePoint];
        [marker fill];
      }
    }

    timelineVerticalPosition += verticalStep;
  }


}

- (void) drawText: (NSString*)str atPoint: (NSPoint) p
{
  NSRect b = [self bounds];
  NSSize size = [str sizeWithAttributes: nil];
  NSPoint target = p;
  if (p.x + size.width > b.size.width){
    target.x = p.x- (b.size.width-p.x+size.width);
  }
  target.y = 0;
  [str drawAtPoint: target withAttributes: nil];
}

- (void) mouseMoved:(NSEvent *)event
{
  mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
  if (dragWhat != Nothing) return;
  double time = [self pixelToTime: mousePoint.x];
  NSString *str = [NSString stringWithFormat: @"%f", time];
  [str drawAtPoint: mousePoint withAttributes: nil];
  [self setNeedsDisplay: YES];
}

- (void)scrollWheel:(NSEvent *)event
{
  mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
  NSRect rect = [[self superview] bounds];
  double mouseTime = [self pixelToTime: mousePoint.x];
  double difPixels = mousePoint.x - rect.origin.x;

  NSRect sf = [self bounds];
  NSRect f = [[self superview] frame];
  if ([event deltaY] > 0){
    sf.size.width += f.size.width*.1;
  }else{
    sf.size.width -= f.size.width*.1;
    if (sf.size.width < f.size.width) sf.size.width = f.size.width;
  }
  [self setFrame: sf];
  [self updatePixelToTimeRatio];
  [self updateRuler];

  double newpixel = [self timeToPixel: mouseTime] - difPixels;
  [self scrollPoint: NSMakePoint(newpixel,0)];
  [self setNeedsDisplay: YES];
}

- (void) mouseDown:(NSEvent *)event
{
  draggingOperation = YES;
}

- (void) mouseDragged: (NSEvent*)event
{
  mousePoint = [self convertPoint:[event locationInWindow] fromView:nil];
  if (dragWhat == Nothing) return;
  double time = [self pixelToTime: mousePoint.x];
  if (dragWhat == Start){
    [controller setStartTimeInterval: time ofFilter: dragFilter];
  }else{
    [controller setEndTimeInterval: time ofFilter: dragFilter];
  }
  [self setNeedsDisplay: YES];
  
}

- (void) mouseUp: (NSEvent*)event
{
  [controller timeSelectionChangedOfFilter: dragFilter];
  dragWhat = Nothing;
  dragFilter = nil;
  draggingOperation = NO;
}

- (void) printCompare
{
  static int cnt = 0;
  NSPrintOperation *op;
  NSMutableData *data = [NSMutableData data];
  op = [NSPrintOperation EPSOperationWithView: self
                                   insideRect: [self bounds]
                                       toData: data];
  [op runOperation];
  NSString *filename = [NSString stringWithFormat: @"%03d-compare.eps", cnt++];
  [data writeToFile: filename atomically: YES];
  NSLog (@"screenshot written to %@", filename);
}


- (void)keyDown:(NSEvent *)theEvent
{
  int code = [theEvent keyCode];
  switch (code){
    case 33: [self printCompare]; break; //P
    default: break;
  }
}


- (void) update
{
  //defining the number of timelines
  nTimeline = [[controller filters] count];

  //defining the largest timestampd found among all timelines
  largestTimestamp = -FLT_MAX;
  id filter;
  NSEnumerator *en = [[controller filters] objectEnumerator];
  while ((filter = [en nextObject])){
    double endTime = [[[filter endTime] description] doubleValue];
    if (endTime > largestTimestamp) largestTimestamp = endTime;
  }
  [self updateRuler];
}

- (void) timeSelectionChangedWithSender: (TimeSync *) filter
{
}

- (void) markerTypeChanged: (id) sender
{
  [self setNeedsDisplay: YES];
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void) zoomIn
{
  NSRect rect = [[self superview] bounds];
  double time = [self pixelToTime: rect.origin.x + rect.size.width/2];

  NSRect sf = [self bounds];
  NSRect f = [[self superview] frame];
  sf.size.width += f.size.width*.1;

  [self setFrame: sf];
  [self updatePixelToTimeRatio];
  [self updateRuler];

  double newpixel = [self timeToPixel: time];
  [self scrollPoint: NSMakePoint(newpixel - rect.size.width/2,0)];
  [self setNeedsDisplay: YES];
}

- (void) zoomOut
{
  NSRect rect = [[self superview] bounds];
  double time = [self pixelToTime: rect.origin.x + rect.size.width/2];

  NSRect sf = [self bounds];
  NSRect f = [[self superview] frame];

  sf.size.width -= f.size.width*.1;
  if (sf.size.width < f.size.width) sf.size.width = f.size.width;

  [self setFrame: sf];
  [self updatePixelToTimeRatio];
  [self updateRuler];

  double newpixel = [self timeToPixel: time];
  [self scrollPoint: NSMakePoint(newpixel - rect.size.width/2,0)];
  [self setNeedsDisplay: YES];
}

- (void) reset
{
  NSRect sf = [self bounds];
  NSRect f = [[self superview] frame];

  sf.size.width = f.size.width;

  [self setFrame: sf];
  [self updatePixelToTimeRatio];
  [self updateRuler];

  [self scrollPoint: NSMakePoint(0,0)];
  [self setNeedsDisplay: YES];
}
@end


@implementation CompareView (Hidden)
- (void) updatePixelToTimeRatio
{
  double width = [self bounds].size.width;
  pixelToTimeRatio = (width - 20)/largestTimestamp; //10 pixel each side
}

- (double) pixelToTime: (double) pixel
{
  return (pixel-10)/pixelToTimeRatio;
}

- (double) timeToPixel: (double) time
{
  return (time*pixelToTimeRatio)+10;
}

- (void) updateRuler
{
  NSRulerView *ruler = [[self enclosingScrollView] horizontalRulerView];
  if (ruler && pixelToTimeRatio != 0){
    // // sets ruler scale
    NSArray *upArray;
    NSArray *downArray;

    upArray = [NSArray arrayWithObjects:
                         [NSNumber numberWithFloat:5.0],
                       [NSNumber numberWithFloat:2.0], nil];
    downArray = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.5],
                         [NSNumber numberWithFloat:0.2], nil];
    [NSRulerView registerUnitWithName:@"Seconds"
                         abbreviation:@"sec"
         unitToPointsConversionFactor:pixelToTimeRatio
                          stepUpCycle:upArray
                        stepDownCycle:downArray];
    [ruler setMeasurementUnits:@"Seconds"];
  }
}
@end
