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
#include "TrivaTree.h"

@implementation TrivaTree
+ (TrivaTree*) nodeWithName: (NSString*)n
                      depth: (int)d
                     parent: (TrivaTree*)p
                   expanded: (BOOL)e
                  container: (PajeContainer*)c
                     filter: (TrivaFilter*)f
{
  return [[[self alloc] initWithName:n
                               depth:d
                              parent:p
                            expanded:e
                           container:c
                              filter:f] autorelease];
}

- (id) initWithName: (NSString*)n
              depth: (int)d
             parent: (TrivaTree*)p
           expanded: (BOOL)e
          container: (PajeContainer*)c
             filter: (TrivaFilter*)f
{
  self = [super initWithName:n
                       depth:d
                      parent:p];
  if (self != nil){
    isExpanded = e;
    isHighlighted = NO;
    container = c;
    filter = f;
    values = [[NSDictionary dictionaryWithDictionary:
        [filter spatialIntegrationOfContainer: container]] retain];
  }
  return self;
}


- (BOOL) expanded
{
  return isExpanded;
}

- (void) setExpanded: (BOOL)e
{
  isExpanded = e;
}

- (void) setBoundingBox: (NSRect) b
{
  bb = b;
}

- (NSRect) boundingBox
{
  return bb;
}

- (BOOL) highlighted
{
  return isHighlighted;
}

- (void) setHighlighted: (BOOL) v
{
  isHighlighted = v;
}

- (void) timeSelectionChanged
{
  [values release];
  values = [[NSDictionary dictionaryWithDictionary:
      [filter spatialIntegrationOfContainer: container]] retain];

  //recursive
  TrivaTree *child;
  NSEnumerator *en = [children objectEnumerator];
  while ((child = [en nextObject])){
    [child timeSelectionChanged];
  }

}
@end