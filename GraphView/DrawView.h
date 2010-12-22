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
#ifndef __GraphView_h
#define __GraphView_h

#include <AppKit/AppKit.h>
#include <Triva/TrivaGraphNode.h>
#include <Tupi/TupiView.h>

@class GraphView;

@interface DrawView : TupiView
{
  GraphView *filter;

  //for screen transformation
  double ratio;
  NSPoint translate;
  NSPoint move; //for use in mouse(down|dragged)

  //interaction states
  BOOL movingSingleNode;
  BOOL selectingArea;

  //drawing selectedArea
  NSRect selectedArea;
  BOOL highlightSelectedArea;
}
- (void) setFilter: (GraphView *)f;
- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation;
- (void) printGraph;
@end


#include "GraphView.h"

#endif
