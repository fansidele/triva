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
#ifndef __TimeSliceDifTree_H_
#define __TimeSliceDifTree_H_

#include <Foundation/Foundation.h>
#include "TimeSliceTree.h"

@interface TimeSliceDifTree : TimeSliceTree
{
  NSMutableDictionary *dif;
  BOOL mergedTree;
}
- (id) initWithTree: (TimeSliceTree*) tree;
- (void) subtractTree: (TimeSliceTree*) tree;
- (NSMutableDictionary*) differences;
- (BOOL) mergedTree;
@end

#endif