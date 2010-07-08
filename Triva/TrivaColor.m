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
#include "TrivaColor.h"

@implementation TrivaColor
- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  self = [super initWithFilter: prov andConfiguration: conf
                      andSpace: YES andName: n andObject: obj];

  //get values
  NSEnumerator *en2 = [[conf objectForKey: @"values"] objectEnumerator];
  id var;
  while ((var = [en2 nextObject])){
    double val = [filter evaluateWithValues: timeSliceValues withExpr: var];
    if (val){
      [values setObject: [NSNumber numberWithDouble: 1]
          forKey: var];
    }
  }
  if ([values count] == 0){
    needSpace = NO;
  }
  return self;
}
@end
