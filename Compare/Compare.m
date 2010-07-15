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
#include "Compare.h"

@implementation Compare
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  selectionStart = 0;
  selectionEnd = 0;
  return self;
}

- (void) setController: (CompareController*) c
{
  controller = c;
}

- (void) timeLimitsChanged
{
  [controller timeLimitsChangedWithSender: self];
  [super timeLimitsChanged];
}

- (void) setTimeIntervalFrom: (double) start to: (double) end
{
  selectionStart = start;
  selectionEnd = end;
  [controller timeLimitsChangedWithSender: self];
  [self timeSelectionChanged];
}

// from the protocol 
- (NSDate *) selectionStartTime
{
  if (selectionStart){
    return [NSDate dateWithTimeIntervalSinceReferenceDate:selectionStart];
  }else{
    return [super selectionStartTime];
  }
}

- (NSDate *) selectionEndTime
{
  if (selectionEnd){
    return [NSDate dateWithTimeIntervalSinceReferenceDate: selectionEnd];
  }else{
    return [super selectionEndTime];
  }
}
@end
