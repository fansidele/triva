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

@interface Treemap : Tree
{
	NSRect rect;
	float value;
	NSColor *color; //the color for this node
	NSMutableArray *aggregatedChildren;
	BOOL highlighted;
}
- (void) setValue: (float) v;
- (float) val;
- (NSRect) treemapRect;
- (void) setTreemapRect: (NSRect)r;
- (void) setColor: (NSColor *) c;
- (NSColor *) color;
- (NSArray *) aggregatedChildren;

/* squarified treemap methods */
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
- (void) calculateTreemapWithWidth: (float) w andHeight: (float) h;

/* search-based methods */
- (Treemap *) searchWith: (NSPoint) point
			limitToDepth: (int) d
			andSelectedValues: (NSSet *) values;

- (NSComparisonResult) compareValue: (Treemap *) other;

/* creating the tree */
- (Treemap *) createTreeWithTimeSliceTree: (TimeSliceTree *) orig
		withValues: (NSSet *) values;

/* highlight methods */
- (BOOL) highlighted;
- (void) setHighlighted: (BOOL) v;
@end

#endif
