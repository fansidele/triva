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
#ifndef __BasicTree_H_
#define __BasicTree_H_
#include <Foundation/Foundation.h>

@interface BasicTree : NSObject
{
  NSString *name;
  BasicTree *parent;
  int depth;
  NSMutableArray *children;
}
+ (BasicTree*) nodeWithName: (NSString*)n
                 depth: (int)d
                parent: (BasicTree*)p;
- (id) initWithName: (NSString*) n
              depth: (int)d
             parent: (BasicTree*)p;
- (NSString *) name;
- (NSArray *) children;
- (BasicTree *) parent;
- (int) depth;
- (int) maxDepth;

- (BasicTree *) searchChildByName: (NSString *) n;

- (void) addChild: (BasicTree *) c;
@end

#endif
