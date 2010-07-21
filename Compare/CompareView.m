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
  [self setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  return self;
}

- (void) resizeSubviewsWithOldSize: (NSSize) size
{
  //this method contains the code to change the subviews' frames
  NSRect b = [self bounds];
  int n = [[self subviews] count];
  NSEnumerator *en = [[self subviews] objectEnumerator];
  double share = b.size.height / n;
  double accum_y = 0;
  Timeline *view;
  while ((view = [en nextObject])){
    NSRect r = NSMakeRect (0, accum_y, b.size.width, share);
    [view setFrame: r];
    accum_y += share;
  }
}

- (void) setController: (CompareController*) cc
{
  controller = cc;
}

- (void) drawRect: (NSRect)r
{
  [[NSColor whiteColor] set];
  [NSBezierPath fillRect: r];
}

- (void) update
{
  NSEnumerator *en = [[controller filters] objectEnumerator];
  NSRect b = [self bounds];
  int n = [[controller filters] count];
  double share = b.size.height / n;
  double accum_y = 0;
  id filter;
  while ((filter = [en nextObject])){
    NSRect r = NSMakeRect (0, accum_y, b.size.width, share);
    Timeline *l = [[Timeline alloc] initWithFrame: NSZeroRect];
    [l setFilter: filter];
    [l setController: controller];
    [l setFrame: r];
    [self addSubview: l];
    [l release];
    accum_y += share;
  }
}

- (void) timeSelectionChangedWithSender: (Compare *) filter
{
  NSEnumerator *en = [[self subviews] objectEnumerator];
  Timeline *view;
  while ((view = [en nextObject])){
    if (filter == [view filter]){
      [view updateSliceMarkersFrames];
    }
  }
}

- (void) markerTypeChanged: (id) sender
{
  NSEnumerator *en = [[self subviews] objectEnumerator];
  Timeline *view;
  while ((view = [en nextObject])){
    [view updateMarkers];
  }
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}
@end
