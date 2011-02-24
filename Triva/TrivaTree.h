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
#ifndef __TrivaTree_H_
#define __TrivaTree_H_

#include <Foundation/Foundation.h>
#include <Triva/BasicTree.h>
#include <General/PajeContainer.h>

@class TrivaFilter;

@interface TrivaTree : BasicTree
{
  NSRect bb;
  BOOL isExpanded;
  BOOL isHighlighted;
  PajeContainer *container;
  TrivaFilter *filter;

  NSMutableDictionary *values;
}
+ (TrivaTree*) nodeWithName: (NSString*)n
                      depth: (int)d
                     parent: (TrivaTree*)p
                   expanded: (BOOL)e
                  container: (PajeContainer*)c
                     filter: (TrivaFilter*)f;
- (id) initWithName: (NSString*)n
              depth: (int)d
             parent: (TrivaTree*)p
           expanded: (BOOL)e
          container: (PajeContainer*)c
             filter: (TrivaFilter*)f;
- (BOOL) expanded;
- (void) setExpanded: (BOOL)e;
- (void) setBoundingBox: (NSRect) b;
- (NSRect) boundingBox;
- (BOOL) highlighted;
- (void) setHighlighted: (BOOL) v;

- (void) timeSelectionChanged;
@end

#include <Triva/TrivaFilter.h>
#endif
