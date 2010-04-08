/*
   Project: SquarifiedTreemap

   Copyright (C) 2010 Free Software Foundation

   Author: Lucas Schnorr,,,

   Created: 2010-02-26 13:36:12 +0100 by schnorr

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
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
                     andHeight: (int) height
                     andValues: (NSSet *) values;
@end

#include "TreemapView.h"
#endif // _SQUARIFIEDTREEMAP_H_

