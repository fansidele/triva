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
#ifndef __Timeline_h_
#define __Timeline_h_

#include <AppKit/AppKit.h>
#include <General/PajeFilter.h>
#include "Compare.h"

@interface Timeline : NSResponder
{
  NSRect bb;
  id filter;
  double ratio;
  NSPoint currentMousePoint;

//  double selStart; // in seconds
//  double selEnd; // in seconds
}
- (void) setFilter: (id) f;
- (void) setBB: (NSRect) r;
- (void) setRatio: (double) r;
- (void) draw;
- (NSRect) bb;
- (void) mouseAtPoint: (NSPoint) p;
- (void) leftMouseAtPoint: (NSPoint) p;
- (void) rightMouseAtPoint: (NSPoint) p;
- (void) updateSelectionInterval;
@end

#endif
