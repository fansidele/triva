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
#include "Entropy.h"

@implementation Entropy (GUI)
- (void) setP: (double) np
{
  if (np < 0) np = 0;
  if (np > 1) np = 1;

  p = np;

  [text setDoubleValue: p];
  [slider setDoubleValue: p];

  [self pChanged];
}

- (void) setVariableName: (NSString *) newname
{
  [variableName release];
  variableName = newname;
  [variableName retain];
  [variablecurrent setStringValue: variableName];

  [self variableChanged];
}

- (void) pSliderChanged: (id) sender
{
  [self setP: [slider doubleValue]];
}

- (void) pTextChanged: (id) sender
{
  [self setP: [text doubleValue]];
}

- (void) variableChanged: (id) sender
{
  [self setVariableName: [variableboxer titleOfSelectedItem]];
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}
@end
