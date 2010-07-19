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
#ifndef __COMPARE_CONT_H
#define __COMPARE_CONT_H

#include <Foundation/Foundation.h>
#include <Triva/TrivaWindow.h>
#include <General/PajeFilter.h>

@class Compare;
@class CompareView;

@interface CompareController : NSObject
{
  NSMutableArray *compareFilters;

  //GUI
  TrivaWindow *window;
  CompareView *view;
  id markerTypeButton;
  id startSynchronized;
  id endSynchronized;

  //for animation
  id frequencySlider;
  id frequencyLabel;
  id forwardSlider;
  id forwardLabel;
  id playButton;
  NSTimer *timer;
}
- (void) check;
- (void) addFilters: (NSArray*) filters;
- (void) timeLimitsChangedWithSender: (Compare*) c;
- (NSArray*) filters;
- (double) largestEndTime;
- (double) smallerSlice;
- (BOOL) startSynchronized;
- (BOOL) endSynchronized;
- (void) setStartTimeInterval: (double) start
                     ofFilter: (id) filter;
- (void) setEndTimeInterval: (double) end
                   ofFilter: (id) filter;

//
- (void) forwardSliderChanged: (id)sender;
- (void) frequencySliderChanged: (id)sender;
- (void) play: (id)sender;
@end

@interface CompareController (TypeHierarchy)
- (NSDictionary *) typeHierarchy: (id) filter ofType: (PajeEntityType*) type;
- (NSDictionary *) typeHierarchy: (id) filter;
- (BOOL) checkTypeHierarchies: (NSArray*)typeHierarchies; //entry method
@end

#include "Compare.h"
#include "CompareView.h"

#endif
