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
#include "Tree.h"

@implementation Tree
- (id) init
{
	self = [super init];
	children = [[NSMutableArray alloc] init];
	maxDepth = -1;
	return self;
}

- (NSString *) name
{
	return name;
}

- (NSArray *) children
{
	return children;
}

- (Tree *) parent
{
	return parent;
}

- (Tree *) searchChildByName: (NSString *) n
{
	int i;
	if ([name isEqualToString: n]){ //that's me
		return self;
	}

	if ([children count] == 0){
		return nil;
	}

	//look up among children
	for (i = 0; i < [children count]; i++){
		Tree *child = [children objectAtIndex: i];
		Tree *found = [child searchChildByName: n];
		if (found){
			return found;
		}
	}
	return nil;
}

- (void) setName: (NSString *) n
{
	if (name != nil){
		[name release];
	}
	name = n;
	[name retain];
}

- (void) setParent: (Tree *) p
{
	parent = p; return;
	/*
	if (parent != nil){
		[parent release];
	}
	parent = p;
	[parent retain];
	*/
}

- (void) addChild: (Tree *) c
{
	[children addObject: c];
}

- (void) dealloc
{
	[name release];
//	[parent release];
	[children release];
	[super dealloc];
}

- (void) removeAllChildren
{
	[children removeAllObjects];
}

- (int) maxDepth
{
	if (maxDepth != -1){
		return maxDepth;
	}

        if ([children count] == 0){
                return depth;
        }

        int max = 0;
        int i;
        for (i = 0; i < [children count]; i++){
                int d = [[children objectAtIndex: i] maxDepth];
                if (d > max){
                        max = d;
                }
        }
	maxDepth = max;
        return max;
}

- (void) setMaxDepth: (int) d
{
	maxDepth = d;
}

- (int) depth
{
        return depth;
}

- (void) setDepth: (int) d
{
        depth = d;
}
@end
