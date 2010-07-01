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
/* All Rights reserved */
#ifndef __GraphConfiguration_h
#define __GraphConfiguration_h

#include <AppKit/AppKit.h>
#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <Triva/TrivaWindow.h>
#include <graphviz/gvc.h>
#include <limits.h>
#include <float.h>
#include <matheval.h>

@interface GraphConfiguration : TrivaFilter
{
  GVC_t *gvc;
  graph_t *graph;

  NSMutableArray *nodes;
  NSMutableArray *edges;

  NSMutableDictionary *configurations; /* nsstring -> nsstring */
  NSDictionary *configuration; //current configuration

  id conf;
  id title;
  id popup;
  id ok;
  TrivaWindow *window;

  BOOL userPositions;
  BOOL graphviz;
  NSRect graphSize;
}
- (void) setConfiguration: (NSDictionary *) conf;
- (void) createGraph;
- (void) redefineNodesEdgesLayout;
- (void) defineMax: (double*)max andMin: (double*)min withScale: (TrivaScale) scale
                fromVariable: (NSString*)var
                ofObject: (NSString*) objName withType: (NSString*) objType;
- (double) evaluateWithValues: (NSDictionary *) values
                withExpr: (NSString *) expr;
- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation;
@end

@interface GraphConfiguration (Interface)
- (void) initInterface;
- (void) updateDefaults;
- (void) refreshPopupAndSelect: (NSString*)toselect;
- (void) apply: (id)sender;
- (void) new: (id)sender;
- (void) change: (id)sender;
- (void) updateTitle: (id) sender;
- (void) del: (id) sender;
@end

#endif
