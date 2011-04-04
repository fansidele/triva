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
#include "TrivaRhombus.h"

@implementation TrivaRhombus
- (void) drawLayout
{
  NSPoint pathCenter = NSMakePoint (bb.size.width/2, bb.size.height/2);
  NSPoint viewCenter = pathCenter;

  NSAffineTransform *t = [NSAffineTransform transform];
  [t translateXBy: viewCenter.x yBy: viewCenter.y];
  [t rotateByDegrees: 45];
  [t translateXBy: -pathCenter.x yBy: -pathCenter.y];
  [t concat];
  [[NSColor whiteColor] set];
  NSRectFill(bb);
  [super drawLayout];
  [t invert];
  [t concat];
}
@end
