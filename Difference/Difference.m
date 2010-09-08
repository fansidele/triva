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
#include "Difference.h"

@implementation Difference
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  return self;
}

- (void) setController: (id) c
{
  controller = c;
}

- (void) timeLimitsChanged
{
  [controller timeLimitsChangedWithSender: self];
  [super timeLimitsChanged];
}

- (void) timeSelectionChanged
{
  [controller timeSelectionChangedWithSender: self];
  [super timeSelectionChanged];
}

- (void) hierarchyChanged
{
  [controller hierarchyChangedWithSender: self];
  [super hierarchyChanged];
}
@end
