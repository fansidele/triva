#include "NUCA.h"

@implementation NUCA
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	gvc = gvContext();
	graph = NULL;
	nodes = nil;
	edges = nil;
	return self;
}

- (void) dealloc
{
	gvFreeContext (gvc);
	agclose (graph);
	[nodes release];
	[edges release];
	[super dealloc];
}

- (void) createNUCAGraph
{
	if (graph){
		agclose (graph);
		[nodes release];
		[edges release];
		graph = NULL;
	}
	graph = agopen ((char *)"graph", AGRAPHSTRICT);
	nodes = [[NSMutableArray alloc] init];
	edges = [[NSMutableArray alloc] init];

	NSEnumerator *types, *en;

	//creating NUCA graph based on processor/switch/cacheL2
	id processorType = [self entityTypeWithName: @"processor"];
	id switchType = [self entityTypeWithName: @"switch"];
	id cacheType = [self entityTypeWithName: @"cacheL2"];
	id psType = [self entityTypeWithName: @"PS"];
	id bsType = [self entityTypeWithName: @"BS"];
	id ssType = [self entityTypeWithName: @"SS"];
	id root = [self rootInstance];
	id type = nil;
	id n = nil;
	id l = nil;

	if (!processorType || !switchType || !cacheType){
		NSLog (@"%s:%d: nuca types (processor=%@, switch=%@, cacheL2=%@) not defined",
			__FUNCTION__, __LINE__, processorType, switchType, cacheType);
		return;
	}
	if (!psType || !bsType || !ssType){
		NSLog (@"%s:%d: nuca types (ps=%@, bs=%@, ss=%@ bb=%@) not defined",
			__FUNCTION__, __LINE__, psType, bsType, ssType);
		return;
	}

	agnodeattr (graph, (char*)"label", (char*)"");
	agraphattr (graph, (char*)"overlap", (char*)"false");
	agraphattr (graph, (char*)"splines", (char*)"true");

	// create graphviz nodes based on processors/switch/cacheL2
	types = [[NSArray arrayWithObjects: processorType,
		switchType, cacheType, nil] objectEnumerator];
	while ((type = [types nextObject])){
		en = [self enumeratorOfContainersTyped: type
			inContainer: root];
		while ((n = [en nextObject])){
			agnode (graph, (char *)[[n name] cString]);
			TrivaGraphNode *node = [[TrivaGraphNode alloc] init];
			[node setName: [n name]];
			[nodes addObject: node];
			[node release];
		}
	}
	
	// create graphviz edges based on links containers
	types = [[NSArray arrayWithObjects: psType,
		bsType, ssType, nil] objectEnumerator];
	while ((type = [types nextObject])){
		en = [self enumeratorOfEntitiesTyped: type
				inContainer: root
				fromTime: [self startTime]
				toTime: [self endTime]
				minDuration: 0];
		while ((l = [en nextObject])){
			id srcContainer = [l sourceContainer];
			id dstContainer = [l destContainer];
			
			const char *src = [[srcContainer name] cString];
			const char *dst = [[dstContainer name] cString];

			Agnode_t *s = agfindnode (graph, (char*)src);
			Agnode_t *d = agfindnode (graph, (char*)dst);
		
			if (!s || !d) continue; //ignore if there is no src or dst
			
			agedge (graph, s, d);

			TrivaGraphEdge *edge = [[TrivaGraphEdge alloc] init];

			[edge setName: [l name]];
			[edge setSource:
				[self findNodeByName:
					[srcContainer name]]];
			[edge setDestination:
				[self findNodeByName:
					[dstContainer name]]];
			[edges addObject: edge];
			[edge release];
		}
	}
	NSLog (@"%s:%d Executing GraphViz Layout... (this might take a while)",
		__FUNCTION__, __LINE__);
	gvFreeLayout (gvc, graph);
	gvLayout (gvc, graph, (char*)"neato");
	NSLog (@"%s:%d GraphViz Layout done", __FUNCTION__, __LINE__);
}

- (void) defineMaxMin
{
	max = 0;
	min = FLT_MAX;

	NSDictionary *values;
        TimeSliceTree *tree;
        NSEnumerator *en = [self enumeratorOfNodes];
        TrivaGraphNode *node;
        while ((node = [en nextObject])){
                tree = [[self timeSliceTree] searchChildByName: [node name]];
                if (tree == nil){
                        NSLog (@"%s:%d time slice tree for node %@ not found",
                                __FUNCTION__, __LINE__, [node name]);
                        continue;
                }
                values = [tree aggregatedValues];
		id numberOfAddresses = [values objectForKey: @"numberOfAddresses"];
		double naddresses = 0;
		if (numberOfAddresses){
			naddresses = [numberOfAddresses doubleValue];
		}
		if (naddresses != 0){
			if (naddresses > max) max = naddresses;
			if (naddresses < min) min = naddresses;
		}
        }
}

- (void) redefineNodesEdgesLayout
{
	if (!graph){
		NSLog (@"%s:%d: platform graph not created",
			__FUNCTION__, __LINE__);
	}

	[self defineMaxMin];

	NSMutableDictionary *values;
	TimeSliceTree *tree;
	NSEnumerator *en = [self enumeratorOfNodes];
	TrivaGraphNode *node;
	while ((node = [en nextObject])){
		tree = [[self timeSliceTree] searchChildByName: [node name]];
		if (tree == nil){
			NSLog (@"%s:%d time slice tree for node %@ not found",
				__FUNCTION__, __LINE__, [node name]);
			continue;
		}
		values = [NSMutableDictionary dictionaryWithDictionary:
			[tree aggregatedValues]];
		Agnode_t *n = agfindnode (graph,
			(char *)[[node name] cString]);
		NSPoint nodePos;
		nodePos.x = ND_coord_i(n).x;
		nodePos.y = ND_coord_i(n).y;
		[node setPosition: nodePos];

		NSRect nodeRect;
		nodeRect.origin.x = nodePos.x;
		nodeRect.origin.y = nodePos.y;

		id numberOfAddresses = [values objectForKey: @"numberOfAddresses"];
		double naddresses = 0;
		if (numberOfAddresses){
			naddresses = [numberOfAddresses doubleValue];
		}
		NSLog (@"%@ %f", [node name], naddresses);

		if (naddresses == 0){
			nodeRect.size.width = 5;
			nodeRect.size.height = 5;
		}else{
			double s = 0;
			s += 20;
			if ((max-min)!=0){
				s += 50 *
					(naddresses - min)/(max-min);
			}
			nodeRect.size.width = s;
			nodeRect.size.height = s;
		}
		[node setSize: nodeRect];

		[node setDrawable: YES];
	}

	en = [self enumeratorOfEdges];
	TrivaGraphEdge *edge;
	while ((edge = [en nextObject])){
		NSRect edgeRect;
		edgeRect.size.width = 0;
		edgeRect.size.height = 0;
		[edge setSize: edgeRect];
		[edge setDrawable: YES];
	}
}

- (void) timeSelectionChanged
{
        static int first_time = 1;
        if (first_time){
                first_time = 0;
        }else{
                [self redefineNodesEdgesLayout];
                [super timeSelectionChanged];
        }
	return;
}

- (void) hierarchyChanged
{
	[self createNUCAGraph];
	[self timeSelectionChanged];
}

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
