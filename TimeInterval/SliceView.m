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
#include "SliceView.h"
#include "TimeInterval.h"

@implementation SliceView
- (void) setFilter: (id) f
{
  filter = f;
}

- (void) drawRect: (NSRect) rect
{
  NSRect b = [self bounds];

  double start = [[[filter startTime] description] doubleValue];
  double end = [[[filter endTime] description] doubleValue];

  double ss = [[[filter selectionStartTime] description] doubleValue];
  double se = [[[filter selectionEndTime] description] doubleValue];

  [[NSColor lightGrayColor] set];
  NSRectFill(b);
  [NSBezierPath strokeRect: b];

  [[NSColor grayColor] set];
  NSRect sel;
  sel.origin.x = ss/(end-start)*b.size.width;
  sel.origin.y = 0;
  sel.size.width = (se-ss)/(end-start)*b.size.width;
  sel.size.height = b.size.height;
  NSRectFill (sel);
  [NSBezierPath strokeRect: sel];
  
  NSRect border;
  border.origin.x = b.origin.x;
  border.origin.y = b.origin.y+1;
  border.size.width = b.size.width-1;
  border.size.height = b.size.height-1;
  [[NSColor blackColor] set];
  [NSBezierPath strokeRect: border];
}

- (void) mouseDown: (NSEvent *) event
{
  [filter switchSliceWindowVisibility];
}
@end
