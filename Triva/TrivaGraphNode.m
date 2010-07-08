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
#include "TrivaGraphNode.h"
#include "NSPointFunctions.h"
#include <float.h>
#include <limits.h>

@implementation TrivaGraphNode
- (id) init
{
  self = [super init];
  bb = NSZeroRect;
  compositions = [[NSMutableDictionary alloc] init];
  currentOutsideBB = NSZeroRect;
  return self;
}

- (void) setType: (NSString *) n
{
  if (type){
    [type release];
  }
  type = n;
  [type retain];
}

- (NSString *) type
{
  return type;
}

- (void) setBoundingBox: (NSRect) b
{
  bb = b;
}

- (NSRect) bb
{
  return bb;
}

- (void) setDrawable: (BOOL) v
{
  drawable = v;
}

- (BOOL) drawable
{
  return drawable;
}

- (void) dealloc
{
  [compositions release];
  [super dealloc];
}

- (void) refresh
{
  //check number of compositions that need space
  int count = 0;
  NSEnumerator *en = [compositions objectEnumerator];
  id composition;
  while ((composition = [en nextObject])){
    if ([composition needSpace]){
      count++;
    }
  }
  en = [compositions objectEnumerator];
  double accum_x = 0;
  currentOutsideBB = NSZeroRect;
  while ((composition = [en nextObject])){
    if ([composition needSpace]){
      NSRect rect = NSMakeRect (bb.origin.x + accum_x,
          bb.origin.y,
          bb.size.width/count,
          bb.size.height);
      [composition refreshWithinRect: rect];
      accum_x += bb.size.width/count;
    }else{
      //if there is more than one composition
      //draw them on the right of the node
      if (NSEqualRects (currentOutsideBB, NSZeroRect)){
        NSRect togo = NSMakeRect (bb.origin.x + bb.size.width + 1,
                                  bb.origin.y, 0, 0);
        [composition refreshWithinRect: togo];
      }else{
        NSRect togo = NSMakeRect (currentOutsideBB.origin.x +
                                        currentOutsideBB.size.width + 1,
                                  currentOutsideBB.origin.y, 0, 0);
        [composition refreshWithinRect: togo];
      }
      currentOutsideBB = [composition bb];
    }
  }
}

- (BOOL) draw
{
  //draw my components
  NSEnumerator *en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [comp draw];
  }

  //draw myself
  [[NSColor lightGrayColor] set];
  [NSBezierPath strokeRect: bb];

  //draw my name
  if (highlighted){
    [name drawAtPoint: NSMakePoint (bb.origin.x + bb.size.width,
          bb.origin.y)
     withAttributes: nil];
  }
  return YES;
}

- (void) setHighlight: (BOOL) highlight
{
  highlighted = highlight;
}

- (BOOL) highlighted
{
  return highlighted;
}

- (void) setTimeSliceTree: (TimeSliceTree *) t
{
  timeSliceTree = t;
}
@end
