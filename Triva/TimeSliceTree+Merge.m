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
#include "TimeSliceTree.h"
#include <float.h>

@implementation TimeSliceTree (Merge)
- (void) subtractTree: (TimeSliceTree*) tree
{
  //recurse
  int i;
  for (i = 0; i < [children count]; i++){
    TimeSliceTree *child = [children objectAtIndex: i];
    TimeSliceTree *treeChild = [[tree children] objectAtIndex: i];
    [child subtractTree: treeChild];
  }

  //calculating differences
  NSEnumerator *en = [timeSliceValues keyEnumerator];
  id key;
  while ((key = [en nextObject])){
    double val = [[timeSliceValues objectForKey: key] doubleValue];
    double treeVal = [[[tree timeSliceValues] objectForKey: key] doubleValue];
    [timeSliceValues setObject: [NSNumber numberWithDouble: val - treeVal] forKey: key];
  }
}
@end
