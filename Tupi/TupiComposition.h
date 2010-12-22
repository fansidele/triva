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
#ifndef __TupiComposition_h_
#define __TupiComposition_h_
#include <Foundation/Foundation.h>
#include <Tupi/Tupi.h>

@class Tupi;

@interface TupiComposition : NSObject
{
  NSString *name;
  NSRect bb; //the bounding box
  Tupi *node; //to which node this composition is part of
  NSDictionary *configuration;

  BOOL needSpace;
  BOOL highlight;
}
+ (id) compositionWithConfiguration: (NSDictionary*) conf
                           withName: (NSString*) n
                         withValues: (NSDictionary*) values
                         withColors: (NSDictionary*) colors
                           withNode: (Tupi*) obj;
- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
                  withValues: (NSDictionary*) values
                  withColors: (NSDictionary*) colors
                    withNode: (Tupi*) obj;

- (void) layoutWithValues: (NSDictionary*) timeSliceValues;
- (void) layoutWithRect: (NSRect) rect;
- (void) drawLayout;

- (void) setHighlight: (BOOL) v;
- (BOOL) highlight;
- (BOOL) needSpace;
- (NSRect) bb;
- (NSString*) name;
- (BOOL) pointInside: (NSPoint)mPoint;
@end

#endif
