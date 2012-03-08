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
#include "../Triva/TrivaGraph.h"
#include "../Triva/TrivaWindow.h"
#include <Tupi/Layout.h>
#include <Tupi/LayoutRunner.h>
#include "DrawView.h"

@interface GraphView : TrivaFilter <TupiProvider>
{
  TrivaGraph *tree;
  DrawView *view;
  TrivaWindow *window;

  BOOL slidersCreated;

  //gui
  id scaleBox;
  id mainVBox;

  //scale sliders
  NSMutableDictionary *scaleSliders;
  NSMutableDictionary *scaleLabels;

  //Tupi layout
  Layout *tupiLayout;
  LayoutRunner *runner;
  NSThread *layoutThread;
}
- (TrivaGraph *) tree;

//from the view
- (void) clickNode: (TrivaGraph*) node;
- (void) rightClickNode: (TrivaGraph*) node;
- (void) moveNode: (TrivaGraph*) node toLocation: (NSPoint) newLoc;
- (void) finishMoveNode: (TrivaGraph *) node;

//from the interface
- (void) clickForceDirected: (id) sender;
- (void) clickResetPositions: (id) sender;
- (void) updateScaleSliders: (id) sender;

- (void) redefineLayout;
@end

#endif
