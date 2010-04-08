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
#ifndef __TREEMAP_H_
#define __TREEMAP_H_
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Triva/Tree.h>
#include <Triva/TimeSliceTree.h>
#include <Triva/TrivaGraphNode.h>

@interface Treemap : TrivaGraphNode
{
	float treemapValue;
	NSMutableArray *aggregatedChildren;
	BOOL highlighted;
	id provider;
}
- (id) initWithTimeSliceTree: (TimeSliceTree*) tree andProvider: (id) prov;
- (void) setTreemapValue: (float) v;
- (float) treemapValue;
- (NSArray *) aggregatedChildren;

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

/* search-based methods */
- (Treemap *) searchWith: (NSPoint) point
			limitToDepth: (int) d;

- (NSComparisonResult) compareValue: (Treemap *) other;

/* highlight methods */
- (BOOL) highlighted;
- (void) setHighlighted: (BOOL) v;

/* provider */
- (void) setProvider: (id) prov;
@end

#endif
