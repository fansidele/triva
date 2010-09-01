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
#ifndef __TrivaGraphNode_h
#define __TrivaGraphNode_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <Triva/Tree.h>
#include <Triva/TimeSliceTree.h>

@class TrivaComposition;
@class TrivaFilter;

@interface TrivaGraphNode : Tree
{
  NSString *type; //node type (entitytype from paje)
  //NSString *name (declared in super class); node name (unique id)
  NSRect bb; //the bounding box of the node (indicates size and position)
  NSMutableDictionary *compositions; //NSString -> TrivaComposition
  BOOL highlighted;
  
  BOOL drawable; //is it ready to draw?

  TimeSliceTree *timeSliceTree; //to show values to the user when highlighted

  NSRect currentOutsideBB;

  NSMutableSet *connectedNodes; //contains the TrivaGraphNode's connected to me
}
- (void) setType: (NSString *) n;
- (NSString *) type;
- (void) setBoundingBox: (NSRect) b;
- (NSRect) bb;
- (void) setDrawable: (BOOL)v;
- (BOOL) drawable;
- (void) refresh;
- (BOOL) draw;
- (void) drawHighlight;
- (void) setHighlight: (BOOL) highlight;
- (BOOL) highlighted;
- (void) setTimeSliceTree: (TimeSliceTree *) t;
- (void) addConnectedNode: (TrivaGraphNode*) n;
- (NSSet*) connectedNodes;

- (BOOL) redefineLayoutWithConfiguration: (NSDictionary *) conf
                            withProvider: (TrivaFilter *) filter
                         withDifferences: (NSDictionary *) differences
                      andTimeSliceValues: (NSDictionary *) values;

- (BOOL) mouseInside: (NSPoint) mPoint;
- (BOOL) mouseInsideCompositions: (NSPoint) mPoint
                   withTransform: (NSAffineTransform*)transform;
@end

#include <Triva/TrivaComposition.h>
#endif
