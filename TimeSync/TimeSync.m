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
#include "TimeSync.h"

@implementation TimeSync
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  selectionStart = -1;
  selectionEnd = -1;
  return self;
}

- (void) setTimeSyncController: (TimeSyncController*) c
{
  timeSyncController = c;
}

- (void) timeLimitsChanged
{
  [timeSyncController timeLimitsChangedWithSender: self];
  [super timeLimitsChanged];
}

- (void) setTimeIntervalFrom: (double) start to: (double) end
{
  double startTime = [[[self startTime] description] doubleValue];
  double endTime = [[[self endTime] description] doubleValue];

  //checks
  if (end > endTime) end = endTime;
  if (start < startTime) start = startTime;

  selectionStart = start;
  selectionEnd = end;

  [self timeSelectionChanged];
}

- (void) timeSelectionChanged
{
  [timeSyncController timeLimitsChangedWithSender: self];
  [super timeSelectionChanged];
}

- (void) setSelectionStart: (double) start
{
  double startTime = [[[self startTime] description] doubleValue];
  double endTime = [[[self endTime] description] doubleValue];

  if (start < startTime) start = startTime;
  if (start > endTime) start = endTime;
  if (selectionEnd >= 0){
    if (start > selectionEnd) start = selectionEnd;
  }
  selectionStart = start;
}

- (void) setSelectionEnd: (double) end
{
  double startTime = [[[self startTime] description] doubleValue];
  double endTime = [[[self endTime] description] doubleValue];
  if (end > endTime) end = endTime;
  if (end < startTime) end = startTime;
  if (selectionStart >= 0){
    if (end < selectionStart) end = selectionStart;
  }
  selectionEnd = end;
}


// from the protocol 
- (NSDate *) selectionStartTime
{
  if (selectionStart >= 0){
    return [NSDate dateWithTimeIntervalSinceReferenceDate:selectionStart];
  }else{
    return [super selectionStartTime];
  }
}

- (NSDate *) selectionEndTime
{
  if (selectionEnd >= 0){
    return [NSDate dateWithTimeIntervalSinceReferenceDate: selectionEnd];
  }else{
    return [super selectionEndTime];
  }
}
@end
