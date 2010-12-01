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
#include <Renaissance/Renaissance.h>
#include <Triva/Triva.h>
#include <graphviz/gvc.h>
#include <limits.h>
#include <float.h>
#include <matheval.h>

//for compatibility with some graphviz's
//installations (ubuntu's lucid, for example)
#ifndef ND_coord
#define ND_coord ND_coord_i
#endif

@interface GraphConfiguration : TrivaFilter
{
  // current graph configuration 
  NSMutableArray *nodes; //list of nodes (TrivaGraphNode*)
  NSMutableArray *edges; //list of edges (TrivaGraphEdge*)
  NSDictionary *configuration; //current configuration

  // interface variables 
  id confView;
  NSTextField *title;
  NSButton *ok;
  TrivaWindow *window;

  // variables defined during configuration parse 
  BOOL userPositionEnabled;
  BOOL graphvizEnabled;
  BOOL configurationParsed;
  BOOL layoutRendered;

  // variables needed to obey protocol
  NSRect graphSize;

  //Graphviz
  GVC_t *gvc;
  graph_t *graph;

  // variables for defining max and min
  NSMutableDictionary *entities; // type -> array of nodes/edges
  NSMutableDictionary *minCache;  // min cache
  NSMutableDictionary *maxCache;  // max cache

  BOOL hideWindow;
}
/*
 * Method called by interface to set a new configuration
 * - This should release nodes and edges attributes
 * - and create a new configuration graph
 */
- (void) setGraphConfiguration: (NSString *) conf
                     withTitle: (NSString *) t;
@end

@interface GraphConfiguration (Interface)
- (void) initInterface;
- (void) refreshInterfaceWithConfiguration: (NSString *) gc
                      withTitle: (NSString *) gct;
- (void) apply: (id)sender;
- (void) updateTitle: (id)sender;
- (void) textDidChange: (id) sender;
@end

@interface GraphConfiguration (Protocol)
@end

@interface GraphConfiguration (Graph)
- (void) destroyGraph;
- (BOOL) parseConfiguration: (NSDictionary *) conf;
- (BOOL) createGraphWithConfiguration: (NSDictionary *) conf;
- (BOOL) definePositionWithConfiguration: (NSDictionary *) conf;
- (BOOL) redefineLayoutOfGraphWithConfiguration: (NSDictionary *) conf;
- (BOOL) redefineLayoutOf: (id) obj withConfiguration: (NSDictionary *) conf;
@end

@interface GraphConfiguration (Position)
- (NSString *) traceUniqueLabel;
- (void) saveGraphPositionsToUserDefaults: (NSString *) label;
- (BOOL) retrieveGraphPositionsFromUserDefaults: (NSString *) label;
- (BOOL) retrieveGraphPositionsFromConfiguration: (NSDictionary *) conf;
- (BOOL) retrieveGraphPositionsFromGraphviz: (NSDictionary *) conf;
@end

#endif
