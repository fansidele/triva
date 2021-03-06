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
#include <AppKit/AppKit.h>
#include "../Triva/TrivaTreemap.h"
#include "../Triva/TrivaFilter.h"
#include "../Triva/TrivaWindow.h"

@class TreemapView;

typedef enum { GlobalZoom, LocalZoom, EntropyZoom } ZoomType;

@interface SquarifiedTreemap  : TrivaFilter
{
  IBOutlet TreemapView *view;
  IBOutlet TrivaWindow *window;

  BOOL recordMode;

  TrivaTreemap *tree;

  ZoomType zType;
}
- (void) setRecordMode;
- (TrivaTreemap *) tree;

//from menu
- (void) globalZoom: (id) sender;
- (void) localZoom: (id) sender;
- (void) entropyZoom: (id) sender;
- (ZoomType) zoomType;
@end

#include "TreemapView.h"
#endif // _SQUARIFIEDTREEMAP_H_

