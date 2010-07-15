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

@implementation Timeline
- (id) init
{
  self = [super init];
  currentMousePoint = NSZeroPoint;
  return self;
}

- (void) setFilter: (id) f
{
  filter = f;
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
  //border
  [[NSColor grayColor] set];
  [NSBezierPath strokeRect: bb];

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

  //draw current mouse point
  if (!NSEqualPoints (NSZeroPoint, currentMousePoint)){
    NSRect t = NSMakeRect (currentMousePoint.x,
                           bb.origin.y + bb.size.height/2 - 10,
                           2,
                           20);
    [[NSColor blackColor] set];
    [NSBezierPath fillRect: t];

    //draw time str
    NSString *str = [NSString stringWithFormat: @"%f", currentMousePoint.x /ratio];
    [str drawAtPoint: currentMousePoint withAttributes: nil];
  }
}

- (NSRect) bb
{
  return bb;
}

- (void) mouseAtPoint: (NSPoint) p
{
  currentMousePoint = p;
}

/*
- (void) mouseDownAtPoint: (NSPoint) p
{
  currentMousePoint = p;
  double newStart, newEnd;
  double clicked = p.x/ratio;

  double selStart = [[[filter selectionStartTime] description] doubleValue];
  double selEnd = [[[filter selectionEndTime] description] doubleValue];

  newStart = selStart;
  newEnd = selEnd;

  //clicked between current time slice
  if (clicked > selStart && clicked < selEnd){
    //if click was closer to start, change start
    //otherwise, change end 
    if ((clicked - selStart) < (selEnd - clicked)){
      newStart = clicked;
    }else{
      newEnd = clicked;
    }
  }else{
    if (clicked < selStart){
      newStart = clicked;
    }else if (clicked > selEnd){
      newEnd = clicked;
    }
  }
  [filter setTimeIntervalFrom: newStart to: newEnd];
}
*/

- (void) leftMouseAtPoint: (NSPoint) p
{
  double clicked = p.x/ratio;
  double selEnd = [[[filter selectionEndTime] description] doubleValue];
  if (clicked < selEnd){
    [filter setTimeIntervalFrom: clicked to: selEnd];
  }
}

- (void) rightMouseAtPoint: (NSPoint) p
{
  double clicked = p.x/ratio;
  double selStart = [[[filter selectionStartTime] description] doubleValue];
  if (clicked > selStart){
    [filter setTimeIntervalFrom: selStart to: clicked];
  }
}
@end
