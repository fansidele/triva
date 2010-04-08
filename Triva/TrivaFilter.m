#include "TrivaFilter.h"

@implementation TrivaFilter
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController:c];
	return self;
}

- (TrivaGraphNode*) findNodeByName: (NSString *)name
{
	return [(TrivaFilter*)inputComponent findNodeByName: name];
}

- (NSEnumerator*) enumeratorOfNodes;
{
	return [(TrivaFilter*)inputComponent enumeratorOfNodes];
}

- (NSEnumerator*) enumeratorOfEdges
{
	return [(TrivaFilter*)inputComponent enumeratorOfEdges];
}

- (NSRect) sizeForGraph
{
	return [(TrivaFilter*)inputComponent sizeForGraph];
}

- (NSRect) rectForNode: (TrivaGraphNode*) node
{
	return [(TrivaFilter*)inputComponent sizeForNode: node];
}

- (NSDictionary*) enumeratorOfValuesForNode: (TrivaGraphNode*) node
{
	return [(TrivaFilter*)inputComponent enumeratorOfValuesForNode: node];
}

- (NSPoint) positionForNode: (TrivaGraphNode*) node
{
	return [(TrivaFilter*)inputComponent positionForNode: node];
}

- (NSRect) sizeForNode: (TrivaGraphNode*) node
{
	return [(TrivaFilter*)inputComponent sizeForNode: node];
}

- (NSDictionary*) enumeratorOfValuesForEdge: (TrivaGraphEdge*) edge
{
	return [(TrivaFilter*)inputComponent enumeratorOfValuesForEdge: edge];
}

- (NSRect) sizeForEdge: (TrivaGraphEdge*) edge
{
	return [(TrivaFilter*)inputComponent sizeForEdge: edge];
}

- (TimeSliceTree *) timeSliceTree
{
	return [(TrivaFilter*)inputComponent timeSliceTree];
}

- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container
{
	return [(TrivaFilter*)inputComponent debugOf: type At: container];
}
@end
