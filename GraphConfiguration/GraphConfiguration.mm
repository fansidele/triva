#include "GraphConfiguration.h"
#include "GraphConfWindow.h"

@implementation GraphConfiguration
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}

	/* create configuration windowdow */
	GraphConfWindow *window = new GraphConfWindow((wxWindow*)NULL);
	window->setController ((id)self);

	/* go through defaults, load the existing configurations */
	//window->add_configuration (NSDictionary);
	NSLog (@"%@ %s", self, __FUNCTION__);

	/* show the windowdow */
	window->Show(true);

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) hierarchyChanged
{
	NSLog (@"%@ %s", self, __FUNCTION__);
	[super hierarchyChanged];
}

/*
- (NSArray *) getContainerTypes
{
	NSMutableArray *ret = [NSMutableArray array];
	NSEnumerator *en = [[self allEntityTypes] objectEnumerator];
	PajeEntityType *type;
	while ((type = [en nextObject])){
		if ([self isContainerEntityType: type]){
			[ret addObject: type];
		}
	}
	return ret;
}

- (NSArray *) getEntityTypes
{
	NSMutableArray *ret = [NSMutableArray array];
	NSEnumerator *en = [[self allEntityTypes] objectEnumerator];
	PajeEntityType *type;
	while ((type = [en nextObject])){
		if (![self isContainerEntityType: type]){
			[ret addObject: type];
		}
	}
	return ret;
}
*/

- (void) setConfiguration: (NSDictionary *) conf
{
	NSLog (@"%@", conf);
}

// implementation the TrivaFilter "protocol" 
- (NSEnumerator*) enumeratorOfNodes
{
	return [nodes objectEnumerator];
}

- (NSEnumerator*) enumeratorOfEdges
{
	return [edges objectEnumerator];
}

- (NSRect) sizeForGraph
{
	NSRect ret;
	ret.origin.x = ret.origin.y = 0;
	ret.size.width = GD_bb(graph).UR.x;
	ret.size.height = GD_bb(graph).UR.y;
	return ret;
}

- (NSDictionary*) enumeratorOfValuesForNode: (TrivaGraphNode*) node
{
	return [node values];
}

- (NSPoint) positionForNode: (TrivaGraphNode*) node
{
	return [node position];
}

- (NSRect) sizeForNode: (TrivaGraphNode*) node
{
	return [node size];
}

- (NSDictionary*) enumeratorOfValuesForEdge: (TrivaGraphEdge*) edge
{
	return [edge values];
}

- (NSRect) sizeForEdge: (TrivaGraphEdge*) edge
{
	return [edge size];
}

- (TrivaGraphNode*) findNodeByName: (NSString *)name
{
	TrivaGraphNode *ret;
	NSEnumerator *en = [nodes objectEnumerator];
	while ((ret = [en nextObject])){
		if ([name isEqualToString: [ret name]]){
			return ret;
		}
	}
	return nil;
}
@end
