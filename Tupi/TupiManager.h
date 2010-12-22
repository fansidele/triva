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
#ifndef __TupiManager_h
#define __TupiManager_h
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Tupi/Tupi.h>
#include <Tupi/TupiConfiguration.h>
#include <graphviz/gvc.h>

//for compatibility with some graphviz's
//installations (ubuntu's lucid, for example)
#ifndef ND_coord
#define ND_coord ND_coord_i
#endif


@interface TupiManager : NSObject <TupiConfiguration>
{
  TupiConfiguration *configuration;
  NSMutableDictionary *nodes;
  Tupi *selectedNode;

  //Graphviz
  GVC_t *gvc;
  graph_t *graph;
}
- (id) initWithConfigurationDictionary: (NSDictionary*) conf;
- (void) addNode: (Tupi*) node;
- (void) connectNode: (Tupi*) n1 toNode: (Tupi*) n2;
- (NSEnumerator*) enumeratorOfNodes;
- (Tupi*) findNodeByName: (NSString*) name;
- (void) layoutOfNode: (Tupi*) node withValues: (NSDictionary*) values andMinValues: (NSDictionary*) min andMaxValues: (NSDictionary*) max andProvider: (id) provider;
- (NSRect) sizeForGraph;

- (void) startAdding;
- (void) endAdding;

//from the view
- (BOOL) searchAndHighlightAtPoint: (NSPoint) p;
- (BOOL) moveHighlightToPoint: (NSPoint) p;
@end

#endif
