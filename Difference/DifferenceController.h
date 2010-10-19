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
#ifndef __DifferenceController_H
#define __DifferenceController_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include <Triva/Triva.h>
#include <Triva/TrivaWindow.h>

typedef enum {Subtract,Ratio,LogDif} TrivaDifferenceOperation;
#define SUBTRACT_OPERATION @"A - B"
#define RATIO_OPERATION    @"max(A,B) / min(A, B)"
#define LOGDIF_OPERATION   @"log (A) - log (B)"

@interface DifferenceController  : TrivaFilter
{
  NSMutableArray *interceptFilters;
  TimeSliceDifTree *mergedTree;

  //GUI
  TrivaWindow *window;
  id numberOfTraceFiles;
  id traceB;
  id traceA;
  id operation;

  TrivaDifferenceOperation configuredOperation;
}
- (void) addFilters: (NSArray *) filters;

- (void) timeLimitsChangedWithSender: (id) sender;
- (void) timeSelectionChangedWithSender: (id) sender;
- (void) hierarchyChangedWithSender: (id) sender;

- (void) updateGUI;
- (void) operationChanged: (id)sender;
@end

#endif
