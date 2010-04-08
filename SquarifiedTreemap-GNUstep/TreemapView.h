/*
   Project: SquarifiedTreemap

   Copyright (C) 2010 Free Software Foundation

   Author: Lucas Schnorr,,,

   Created: 2010-02-26 13:58:50 +0100 by schnorr

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

#ifndef _TREEMAPVIEW_H_
#define _TREEMAPVIEW_H_

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "SquarifiedTreemap.h"

@interface TreemapView : NSView
{
	int maxDepthToDraw;
	SquarifiedTreemap *filter;
	id current;

}
- (void) setMaxDepthToDraw: (int) d;
- (int) maxDepthToDraw;
- (void) setFilter: (SquarifiedTreemap *) f;
@end

#include "TreemapView.h"
#endif // _TREEMAPVIEW_H_

