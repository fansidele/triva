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
