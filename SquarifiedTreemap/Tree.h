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
#ifndef __TREE_H_
#define __TREE_H_

#include <Foundation/Foundation.h>

@interface Tree : NSObject
{
	NSString *name;
	Tree *parent;
	NSMutableArray *children;
	int depth;
	int maxDepth; /* for caching */
}
- (int) depth;
- (void) setDepth: (int) d;
- (int) maxDepth;
- (int) setMaxDepth: (int) d;

- (NSString *) name;
- (NSArray *) children;
- (Tree *) parent;
- (Tree *) searchChildByName: (NSString *) n;

- (void) setName: (NSString *) n;
- (void) setParent: (Tree *) p;
- (void) addChild: (Tree *) c;
- (void) removeAllChildren;
@end

#endif
