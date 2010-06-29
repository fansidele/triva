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
#ifndef __TrivaFilter_h
#define __TrivaFilter_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "TrivaGraphNode.h"
#include "TrivaGraphEdge.h"
#include "TimeSliceTree.h"

typedef enum {Local,Global} TrivaScale;

@class TrivaGraphNode;
@class TrivaGraphEdge;

@interface TrivaFilter  : PajeFilter
- (TrivaGraphNode*) findNodeByName: (NSString *)name;
- (NSEnumerator*) enumeratorOfNodes;
- (NSEnumerator*) enumeratorOfEdges;
- (NSRect) sizeForGraph;
- (double) graphComponentScaling; /* graphconf --> graphview */
- (void) graphComponentScalingChanged; /* graphconf <-- graphview */

/* aggregated stuff (methods trapped by TimeSliceAggregation component */
- (TimeSliceTree *) timeSliceTree;

/* auxiliary methods */
- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container;
- (double) evaluateWithValues: (NSDictionary *) values
                withExpr: (NSString *) expr;
- (void) defineMax: (double*)max andMin: (double*)min withScale: (TrivaScale) scale //TODO : remove
                fromVariable: (NSString*)var
                ofObject: (NSString*) objName withType: (NSString*) objType;
- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation; //TODO :remove
@end

#endif
