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

#ifndef _SQUARIFIEDTREEMAP_H_
#define _SQUARIFIEDTREEMAP_H_

#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <Triva/TimeSliceTree.h>
#include "Treemap.h"

@class TreemapView;

@interface SquarifiedTreemap  : TrivaFilter
{
	IBOutlet TreemapView *view;

	TimeSliceTree *timeSliceTree;
	Treemap *currentTreemap;
	BOOL mustBeUpdated;
}
- (Treemap *) treemapWithWidth: (int) width
                     andHeight: (int) height;
@end

#include "TreemapView.h"
#endif // _SQUARIFIEDTREEMAP_H_

