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
#ifndef __TrivaGraph_H_
#define __TrivaGraph_H_
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Triva/BasicTree.h>
#include <Triva/TimeSliceTree.h>
#include <Triva/TrivaGraphNode.h>

@interface TrivaGraph : TrivaTree
{
}
+ (TrivaGraph*) nodeWithName: (NSString*)n
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

/* entry point for squarified algorithm */
//- (void) refreshWithBoundingBox: (NSRect) bb;

/* draw (called by view, must be after refreshWithBoundingBox) */
//- (void) drawTreemap;
//- (void) drawBorder;

/* search-based methods */
- (TrivaGraph *) searchWith: (NSPoint) point
      limitToDepth: (int) d;
@end

#endif
