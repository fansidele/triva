#ifndef __TrivaFilter_h
#define __TrivaFilter_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "TrivaGraphNode.h"
#include "TrivaGraphEdge.h"
#include "TimeSliceTree.h"

@interface TrivaFilter  : PajeFilter
- (TrivaGraphNode*) findNodeByName: (NSString *)name;
- (NSEnumerator*) enumeratorOfNodes;
- (NSEnumerator*) enumeratorOfEdges;
- (NSRect) sizeForGraph;

/* nodes */
- (NSDictionary*) enumeratorOfValuesForNode: (TrivaGraphNode*) node;
- (NSPoint) positionForNode: (TrivaGraphNode*) node;
- (NSRect) sizeForNode: (TrivaGraphNode*) node;

/* edges */
- (NSDictionary*) enumeratorOfValuesForEdge: (TrivaGraphEdge*) edge;
- (NSRect) sizeForEdge: (TrivaGraphEdge*) edge;

/* aggregated stuff (methods trapped by TimeSliceAggregation component */
- (TimeSliceTree *) timeSliceTree;
@end

#endif
