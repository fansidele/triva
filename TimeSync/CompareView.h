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
#ifndef __COMPARE_VIEW_H
#define __COMPARE_VIEW_H

#include <AppKit/AppKit.h>
#include <float.h>
#include "TimeSyncController.h"

typedef enum { Start, End, Nothing } DragWhat;

@interface CompareView : NSView
{
  TimeSyncController *controller; 

  int nTimeline; //number of timelines
  double largestTimestamp; //largest timeline among all

  double pixelToTimeRatio; //pixel to time

  NSPoint mousePoint;

  NSMutableArray *timelines;

  DragWhat dragWhat;
  id dragFilter;
  BOOL draggingOperation;
}
- (void) setController: (TimeSyncController*) cc;
- (void) timeSelectionChangedWithSender: (TimeSync *) filter;
- (void) update;

- (void) markerTypeChanged: (id) sender;

- (void) drawText: (NSString*)str atPoint:(NSPoint)p;

- (void) updatePixelToTimeRatio;
- (double) pixelToTime: (double) pixel;
- (double) timeToPixel: (double) time;
@end

#endif
