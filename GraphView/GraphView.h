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
#ifndef __GraphView_H
#define __GraphView_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include <Triva/Triva.h>
#include <graphviz/gvc.h>
#include "DrawView.h"

@interface GraphView : TrivaFilter
{
  TrivaGraph *tree;

  //Graphviz
  GVC_t *gvc;
  graph_t *graph;

  NSMutableSet *graphNodes; /* of TrivaGraph, contains all the nodes
                               that currently participate in the graph */

  IBOutlet DrawView *view;
  TrivaWindow *window;

  BOOL recordMode;

  BOOL executeThread;
  NSThread *thread;
}
- (void) setRecordMode;
- (TrivaGraph *) tree;
- (graph_t *) graphviz;

- (void) addGraphNode: (TrivaGraph*) n;
- (void) removeGraphNode: (TrivaGraph*) n;
- (void) removeGraphNodes;
@end

#endif
