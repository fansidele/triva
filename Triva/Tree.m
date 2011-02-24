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
- (Tree*) nodeWithName: (NSString*)n
                 depth: (int)d
                parent: (Tree*)p
{
  return [[[Tree alloc] initWithName: n
                               depth: d
                              parent: p] autorelease];
}

- (id) initWithName: (NSString*) n
              depth: (int)d
             parent: (Tree*)p
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

- (Tree *) parent
{
  return parent;
}

- (int) depth
{
        return depth;
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

- (void) addChild: (Tree *) c
{
  [children addObject: c];
}
@end
