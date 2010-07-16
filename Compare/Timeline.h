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

enum Target { SelectionStart, SelectionEnd};

@interface Timeline : NSView
{
  id filter;
  id controller;
  NSPoint currentMousePoint;
  double ratio;

  double currentTarget;
  double offsetFromMouseToTarget;
  BOOL targetSelected;
  BOOL targetDragging;
  enum Target target;

//  double selStart; // in seconds
//  double selEnd; // in seconds
}
- (void) setFilter: (id) f;
- (void) setController: (id) c;
@end

#endif
