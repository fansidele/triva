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
#ifndef __TrivaTreemap_H_
#define __TrivaTreemap_H_
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "TrivaTree.h"

@interface TrivaTreemap : TrivaTree
{
  double treemapValue;
  double offset;

  NSMutableArray *valueChildren;
}
+ (TrivaTreemap*) nodeWithName: (NSString*)n
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
- (void) setTreemapValue: (double)v;
- (double) treemapValue;
- (void) setOffset: (double) o; //recursive call
- (double) offset;

/* squarified treemap algorithm */
- (double) worstf: (NSArray *) list
                withSmallerSize: (double) w
                withFactor: (double) factor;
- (NSRect)layoutRow: (NSArray *) row
                withSmallerSize: (double) w
                withinRectangle: (NSRect) r
                withFactor: (double) factor;
- (void) squarifyWithOrderedChildren: (NSMutableArray *) list
                andSmallerSize: (double) w
                andFactor: (double) factor;
- (void) calculateTreemapRecursiveWithFactor: (double) factor;

/* entry point for squarified algorithm */
- (void) refreshWithBoundingBox: (NSRect) bb;

/* draw (called by view, must be after refreshWithBoundingBox) */
- (void) drawTreemap;
- (void) drawHighlighted;
- (void) drawBorder;

/* search-based methods */
- (TrivaTreemap *) searchWith: (NSPoint) point
      limitToDepth: (int) d;

- (NSComparisonResult) compareValue: (TrivaTreemap *) other;

/* request hierarchy */
- (NSMutableArray *) recursiveHierarchy; /* internal, called by next method */
- (NSMutableArray *) hierarchy; /* get the hierarchy up to this node */
@end

#endif
