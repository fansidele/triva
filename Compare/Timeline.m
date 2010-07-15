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

@implementation Timeline
- (id) init
{
  self = [super init];
  currentMousePoint = NSZeroPoint;
  currentTarget = -1;
  targetSelected = NO;
  return self;
}

- (void) setFilter: (id) f
{
  filter = f;
}

- (void) setView: (NSView *) v
{
  view = v;
}

- (void) setBB: (NSRect) r
{
  bb = r;
}

- (void) setRatio: (double) r
{
  ratio = r;
}

- (void) updateSelectionInterval
{
/*
  selStart = [[[filter selectionStartTime] description] doubleValue];
  selEnd = [[[filter selectionEndTime] description] doubleValue];
*/
}

- (void) draw
{
  //no-border
  //[[NSColor grayColor] set];
  //[NSBezierPath strokeRect: bb];

  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  double filterEndTime = [[[filter endTime] description] doubleValue];

  //drawing the timeline
  NSRect t = NSMakeRect (bb.origin.x,
                         bb.origin.y + bb.size.height/2 - 1,
                         filterEndTime * ratio,
                         2);
  [[NSColor blackColor] set];
  [NSBezierPath fillRect: t];

  //drawing the selected time slice
  NSRect s = NSMakeRect (selStart * ratio,
                         bb.origin.y + bb.size.height/2 - 2,
                         (selEnd * ratio) - (selStart * ratio),
                         4);
  [[NSColor lightGrayColor] set];
  [NSBezierPath fillRect: s];

  //draw current mouse point (if it is not dragging)
  if (!NSEqualPoints (NSZeroPoint, currentMousePoint) && !targetDragging){
    NSPoint pstr = NSMakePoint (currentMousePoint.x,
                                bb.origin.y + bb.size.height/2 + 10);
    NSRect t = NSMakeRect (pstr.x,
                           pstr.y - 20,
                           2,
                           20);
    [[NSColor blackColor] set];
    [NSBezierPath fillRect: t];

    //draw time str
    NSString *str;
    str = [NSString stringWithFormat: @"%f", currentMousePoint.x /ratio];
    [str drawAtPoint: pstr withAttributes: nil];
  }

  //draw currentTarget
  if (currentTarget >= 0){
    NSPoint p = NSMakePoint(currentTarget * ratio,
                            bb.origin.y + bb.size.height/2);
    [[NSColor blueColor] set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter: p
                                     radius: 5
                                 startAngle: 0
                                   endAngle: 360];
    [path fill];
    if (targetSelected){
      NSBezierPath *path = [NSBezierPath bezierPath];
      [path appendBezierPathWithArcWithCenter: p
                                       radius: 7
                                   startAngle: 0
                                     endAngle: 360];
      [[NSColor redColor] set];
      [path stroke];

      NSString *str;
      str = [NSString stringWithFormat: @"%f", currentTarget];
      NSPoint pstr = NSMakePoint (p.x, p.y + 10);
      [str drawAtPoint: pstr withAttributes: nil];
    }
  }
}

- (NSRect) bb
{
  return bb;
}

- (void) mouseMoved: (NSEvent *) event
{
  NSPoint p = [view convertPoint:[event locationInWindow] fromView:nil];
  currentMousePoint = p;
  double mousePosition = p.x/ratio;
  double aux = FLT_MAX;

  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double selEnd = [[[filter selectionEndTime] description] doubleValue];

  //search for time slice borders
  double candidate = fabs (mousePosition - selStart);
  if (candidate < aux){
    aux = candidate;
    currentTarget = selStart;
    target = SelectionStart;
  }
  candidate = fabs (mousePosition - selEnd);
  if (candidate < aux){
    aux = candidate;
    currentTarget = selEnd;
    target = SelectionEnd;
  }

  //search for markers
  //TODO
}

- (void) mouseDown: (NSEvent *) event
{
  NSPoint p = [view convertPoint:[event locationInWindow] fromView:nil];
  double mousePosition = p.x/ratio;

  targetSelected = YES;
  offsetFromMouseToTarget = currentTarget - mousePosition;
  [view setNeedsDisplay: YES];
}

- (void) mouseDragged: (NSEvent *) event
{
  NSPoint p = [view convertPoint:[event locationInWindow] fromView:nil];
  double mousePosition = p.x/ratio;

  targetDragging = YES;

  currentTarget = mousePosition + offsetFromMouseToTarget;

  //move
  [view setNeedsDisplay: YES];
}

- (void) mouseUp: (NSEvent *) event
{
  NSPoint p = [view convertPoint:[event locationInWindow] fromView:nil];
  currentMousePoint = p;
  double mousePosition = p.x/ratio;

  targetSelected = NO;
  targetDragging = NO;
 
  //is selection start
  currentTarget = mousePosition + offsetFromMouseToTarget;

  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double selEnd = [[[filter selectionEndTime] description] doubleValue];

  if (target == SelectionStart) {
    [filter setTimeIntervalFrom: currentTarget to: selEnd];
  }else if (target == SelectionEnd){
    [filter setTimeIntervalFrom: selStart to: currentTarget];
  }

  //treats the change of target
}

/*
- (BOOL)acceptsFirstResponder
{
  return YES;
}
*/
@end
