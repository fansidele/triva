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
#include "BasicTree.h"

@implementation BasicTree
+ (BasicTree*) nodeWithName: (NSString*)n
                 depth: (int)d
                parent: (BasicTree*)p
{
  return [[[self alloc] initWithName: n
                               depth: d
                              parent: p] autorelease];
}

- (id) initWithName: (NSString*) n
              depth: (int)d
             parent: (BasicTree*)p
{
  self = [super init];
  children = [[NSMutableArray alloc] init];
  depth = d;
  parent = p;
  name = [[NSString stringWithString: n] retain];
  return self;
}

- (void) dealloc
{
  [name release];
  [children release];
  [super dealloc];
}

- (NSString *) name
{
  return name;
}

- (NSArray *) children
{
  return children;
}

- (BasicTree *) parent
{
  return parent;
}

- (int) maxDepth
{
  int ret;
  NSEnumerator *en = [children objectEnumerator];
  BasicTree *child;
  ret = depth;
  while ((child = [en nextObject])){
    int childDepth = [child maxDepth];
    if (childDepth > ret) ret = childDepth;
  }
  return ret;
}

- (int) depth
{
        return depth;
}

- (BasicTree *) searchChildByName: (NSString *) n
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
    BasicTree *child = [children objectAtIndex: i];
    BasicTree *found = [child searchChildByName: n];
    if (found){
      return found;
    }
  }
  return nil;
}

- (void) addChild: (BasicTree *) c
{
  [children addObject: c];
}
@end
