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

@implementation CompareView
- (id) initWithFrame: (NSRect) r
{
  self = [super initWithFrame: r];
  timelines = [[NSMutableArray alloc] init];
  sameMouseForAll = NO;
  return self;
}

- (void) setController: (CompareController*) cc
{
  controller = cc;
}

- (void) updateFilterDate
{
  //find out largest trace file
  NSArray *filters = [controller filters];
  NSEnumerator *en = [filters objectEnumerator];
  NSDate *largest = [NSDate distantPast];
  id filter;
  while ((filter = [en nextObject])){
    if ([largest compare: [filter endTime]] == NSOrderedAscending){
      largest = [filter endTime];
    }
    largest = [largest laterDate: [filter endTime]];
  }
  largestEndTime = [[largest description] doubleValue];

  //creating timelines
  [timelines removeAllObjects];
  en = [filters objectEnumerator];
  while ((filter = [en nextObject])){
    Timeline *l = [[Timeline alloc] init];
    [l setFilter: filter];
    [l setView: self];
    [timelines addObject: l];
    [l release];
  }
}

- (void) drawRect: (NSRect) rect
{
  NSRect bounds = [self bounds];

  [[NSColor whiteColor] set];
  NSRectFill (bounds);

  //updating ratio
  ratio = bounds.size.width / largestEndTime;

  //updating timelines bounds
  int n = [timelines count];
  double share = bounds.size.height / n;
  double accum_y = 0;
  Timeline *timeline;
  NSEnumerator *en = [timelines objectEnumerator];
  while ((timeline = [en nextObject])){
    NSRect r = NSMakeRect (0, accum_y, bounds.size.width, share);
    accum_y += share;

    [timeline setBB: r];
    [timeline setRatio: ratio];
//    [timeline updateSelectionInterval];
  }

  //draw
  en = [timelines objectEnumerator];
  while ((timeline = [en nextObject])){
    [timeline draw];
  }
}

- (Timeline*) searchForTimelineAtPoint: (NSPoint)p
{
  Timeline *timeline;
  NSEnumerator *en = [timelines objectEnumerator];
  while ((timeline = [en nextObject])){
    if (NSPointInRect (p, [timeline bb])){
      return timeline;
    }
  }
  return nil;
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];

  //search for timeline 
  Timeline *timeline = [self searchForTimelineAtPoint: p];
  [timeline mouseMoved: event];
  [self setNeedsDisplay: YES];
}

- (void) mouseDown: (NSEvent *) event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  //search for timeline 
  Timeline *timeline = [self searchForTimelineAtPoint: p];
  [timeline mouseDown: event];
}

- (void) mouseDragged:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  //search for timeline 
  Timeline *timeline = [self searchForTimelineAtPoint: p];
  [timeline mouseDragged: event];
}

- (void) mouseUp: (NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  //search for timeline 
  Timeline *timeline = [self searchForTimelineAtPoint: p];
  [timeline mouseUp: event];
}
@end

