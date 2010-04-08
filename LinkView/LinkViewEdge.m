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
#include "LinkViewEdge.h"
#include <math.h>

@implementation LinkViewEdge
- (void) draw
{
//	double offset = 2;
//	NSRect r = NSMakeRect (bb.origin.x+offset, bb.origin.y+offset,
//			bb.size.width-2*offset, bb.size.height-2*offset);
//	[NSBezierPath strokeRect: r];
	[NSBezierPath strokeRect: bb];
//	[name drawAtPoint: NSMakePoint (bb.origin.x, bb.origin.y)
  //         withAttributes: nil];
}
@end
