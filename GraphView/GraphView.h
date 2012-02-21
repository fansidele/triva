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
#include <graphviz/gvc.h>
#include "../Triva/TrivaGraph.h"
#include "../Triva/TrivaWindow.h"
#include "DrawView.h"

@interface GraphView : TrivaFilter
{
  TrivaGraph *tree;

  //Graphviz
  GVC_t *gvc;
  graph_t *graph;

  NSMutableSet *forceDirectedNodes; /* of TrivaGraph, contains all the nodes
                                       that currently participate in the
                                       graph */
  NSMutableSet *forceDirectedIgnoredNodes; /* of TrivaGraph, contains nodes
                                              that does not receive updates
                                              from force-directed algorithm */

  IBOutlet DrawView *view;
  TrivaWindow *window;

  BOOL recordMode;
  BOOL slidersCreated;

  BOOL executeThread;
  NSThread *thread;
  NSConditionLock *lock;

  //gui
  NSSlider *springSlider;
  NSSlider *chargeSlider;
  NSSlider *dampingSlider;
  NSTextField *springLabel;
  NSTextField *chargeLabel;
  NSTextField *dampingLabel;
  id scaleBox;
  id mainVBox;

  //scale sliders
  NSMutableDictionary *scaleSliders;
  NSMutableDictionary *scaleLabels;

  //User options
  BOOL expandAll;
  BOOL exportDot;
}
- (void) startForceDirectedThread;
- (void) stopForceDirectedThread;
- (void) setRecordMode;
- (TrivaGraph *) tree;

- (void) forceDirectedGraph: (id) sender;
//aditional methods to complete protocol (used only within this component)
- (void) addForceDirectedIgnoredNode: (TrivaGraph*) n;
- (void) removeForceDirectedNode: (TrivaGraph*) n;
- (void) removeForceDirectedIgnoredNode: (TrivaGraph*) n;

//from the interface
- (void) forceDirected: (id) sender;
- (void) updateLabels: (id) sender;
- (void) resetPositions: (id) sender;
- (void) updateScaleSliders: (id) sender;

- (void) redefineLayout;
@end

#endif
