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

- (TimeSliceTree *) timeSliceTree
{
	return [(TrivaFilter*)inputComponent timeSliceTree];
}

- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container
{
	return [(TrivaFilter*)inputComponent debugOf: type At: container];
}

- (double) evaluateWithValues: (NSDictionary *) values
                withExpr: (NSString *) expr
{
	return [(TrivaFilter*)inputComponent evaluateWithValues: values
			withExpr: expr];
}

- (void) defineMax: (double*)max andMin: (double*)min withScale: (TrivaScale) scale
                fromVariable: (NSString*)var
                ofObject: (NSString*) objName withType: (NSString*) objType
{
	return; // TODO: remove
}

- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation
{
	return nil; // TODO: remove
}
@end
