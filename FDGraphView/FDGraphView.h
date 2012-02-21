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
#ifndef __FDGraphView_H
#define __FDGraphView_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "../Triva/TrivaGraph.h"
#include "../Triva/TrivaWindow.h"
#include <Tupi/Layout.h>
#include <Tupi/LayoutRunner.h>

@interface FDGraphView : TrivaFilter <TupiProvider>
{
  TrivaGraph *tree;

  NSMutableSet *forceDirectedNodes; /* of TrivaGraph, contains all the nodes
                                       that currently participate in the
                                       graph */
  NSMutableSet *forceDirectedIgnoredNodes; /* of TrivaGraph, contains nodes
                                              that does not receive updates
                                              from force-directed algorithm */

  id view;
  TrivaWindow *window;

  BOOL recordMode;
  BOOL slidersCreated;

  //gui
  id scaleBox;
  id mainVBox;

  //scale sliders
  NSMutableDictionary *scaleSliders;
  NSMutableDictionary *scaleLabels;

  //User options
  BOOL expandAll;
  BOOL exportDot;

  //Tupi layout
  Layout *tupiLayout;
  LayoutRunner *runner;
  NSThread *layoutThread;
}
- (void) setRecordMode;
- (TrivaGraph *) tree;

//aditional methods to complete protocol (used only within this component)
- (void) addForceDirectedIgnoredNode: (TrivaGraph*) n;
- (void) removeForceDirectedNode: (TrivaGraph*) n;
- (void) removeForceDirectedIgnoredNode: (TrivaGraph*) n;

//from the interface
- (void) clickForceDirected: (id) sender;
- (void) clickResetPositions: (id) sender;
- (void) updateScaleSliders: (id) sender;

- (void) redefineLayout;
@end

#endif
