#include "SimGrid.h"

//following values should be in pixels
//this should not be declared here
#define DEFAULT_SIZE	2
#define ROUTER_SIZE	5
#define MAX_HOST_SIZE	50
#define MAX_LINK_SIZE	25

@implementation SimGrid
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	gvc = gvContext();
	platformGraph = NULL;
	nodes = nil;
	edges = nil;
	return self;
}

- (void) dealloc
{
	gvFreeContext (gvc);
	agclose (platformGraph);
	[nodes release];
	[edges release];
	[super dealloc];
}

- (void) defineMaxMin
{
	maxPower = maxBandwidth = 0;
	minPower = minBandwidth = FLT_MAX;

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
		double power = [[values objectForKey: @"power"] doubleValue];
		if (power != 0){
			if (power > maxPower) maxPower = power;
			if (power < minPower) minPower = power;
		}
	}

	en = [self enumeratorOfEdges];
	TrivaGraphEdge *edge;
	while ((edge = [en nextObject])){
		tree = [[self timeSliceTree] searchChildByName: [edge name]];
		if (tree == nil){
			NSLog (@"%s:%d time slice tree for edge %@ not found",
				__FUNCTION__, __LINE__, [node name]);
			continue;
		}
		values = [tree aggregatedValues];
		double bw = [[values objectForKey: @"bandwidth"] doubleValue];
		if (bw != 0){
			if (bw > maxBandwidth) maxBandwidth = bw;
			if (bw < minBandwidth) minBandwidth = bw;
		}
	}
}

- (void) redefineNodesEdgesLayout
{
	if (!platformGraph){
		NSLog (@"%s:%d: platform graph not created",
			__FUNCTION__, __LINE__);
		return;
	}

	[self defineMaxMin];
	NSMutableDictionary *values;
	TimeSliceTree *tree;

	NSEnumerator *en = [self enumeratorOfNodes];
	TrivaGraphNode *node;
	while ((node = [en nextObject])){
		//getting values integrated in time
		tree = [[self timeSliceTree] searchChildByName: [node name]];
		if (tree == nil){
			NSLog (@"%s:%d time slice tree for node %@ not found",
				__FUNCTION__, __LINE__, [node name]);
			continue;
		}
		values = [NSMutableDictionary dictionaryWithDictionary:
				[tree aggregatedValues]];

		//getting x,y position from graphviz
		Agnode_t *n = agfindnode (platformGraph,
				(char *)[[node name] cString]);
		NSPoint nodePos;
		nodePos.x = ND_coord_i(n).x;
		nodePos.y = ND_coord_i(n).y;
		[node setPosition: nodePos];

		//getting width,height from power variable
		double power = [[values objectForKey: @"power"] doubleValue];
		NSRect nodeRect;
		nodeRect.origin.x = nodePos.x;
		nodeRect.origin.y = nodePos.y;
		/* COMMENT: all this calculations should not be done here
		 * because they are related to the graphics, instead of the
		 * semantics behind the power related to the size
		 */
		if (power == 0){
			nodeRect.size.width = ROUTER_SIZE;
			nodeRect.size.height = ROUTER_SIZE;
		}else{
			double s = 0;
			if ((maxPower)!=0){
				s = MAX_HOST_SIZE*
				     (power)/(maxPower);
			}
			nodeRect.size.width = s;
			nodeRect.size.height = s;
		}
		[node setSize: nodeRect];
		[values removeObjectForKey: @"power"];

		//getting integrated values and add them proportionally to
		//the previously used integrated value to configure size
		id key;
		NSEnumerator *en2 = [values keyEnumerator];
		NSMutableDictionary *nodeGraphValues;
		nodeGraphValues = [NSMutableDictionary dictionary];
		while ((key = [en2 nextObject])){
			double val;
			val = [[values objectForKey: key] doubleValue];
			if (power && val){
				double res = val/power;
				if ((int)res > 1){
					NSLog (@"%s:%d value for category %@ is greater than 1 "
						"(%f). The size for this node is %f",
						__FUNCTION__, __LINE__,
						key, res, power);
				}
				[nodeGraphValues setObject:
					[NSNumber numberWithDouble: val/power]
						    forKey: key];
			}
		}
		[node setValues: nodeGraphValues];
		[node setSeparation: YES];
		[node setDrawable: YES];
	}

	en = [self enumeratorOfEdges];
	TrivaGraphEdge *edge;
	while ((edge = [en nextObject])){
		tree = [[self timeSliceTree] searchChildByName: [edge name]];
		if (tree == nil){
			NSLog (@"%s:%d time slice tree for edge %@ not found",
				__FUNCTION__, __LINE__, [edge name]);
			continue;
		}
		values = [NSMutableDictionary dictionaryWithDictionary:
				[tree aggregatedValues]];
		double bandwidth = [[values objectForKey: @"bandwidth"] doubleValue];
		NSRect edgeRect;
		if (bandwidth == 0){
			edgeRect.size.width = 0;
			edgeRect.size.height = 0;
		}else{	
			double s = 0;
			if ((maxBandwidth) != 0){
				s = MAX_LINK_SIZE *
					(bandwidth) / (maxBandwidth);
			}
			edgeRect.size.width = s;
			edgeRect.size.height = s;
		}
		[edge setSize: edgeRect];
		[values removeObjectForKey: @"bandwidth"];

		//getting integrated values and add them proportionally to
		//the previously used integrated value to configure size
		id key;
		NSEnumerator *en2 = [values keyEnumerator];
		NSMutableDictionary *edgeGraphValues;
		edgeGraphValues = [NSMutableDictionary dictionary];
		while ((key = [en2 nextObject])){
			double val;
			val = [[values objectForKey: key] doubleValue];
			if (bandwidth && val){
				[edgeGraphValues setObject:
					[NSNumber numberWithDouble: val/bandwidth]
						    forKey: key];
			}
		}
		[edge setValues: edgeGraphValues];
		[edge setDrawable: YES];
	}
}

- (void) createSimGridPlatformGraph
{
	//close before starting a new one
	if (platformGraph){
		[nodes release];
		[edges release];
		agclose (platformGraph); 
		platformGraph = NULL;
	}
	platformGraph = agopen ((char *)"platformGraph", AGRAPHSTRICT);
	nodes = [[NSMutableArray alloc] init];
	edges = [[NSMutableArray alloc] init];

	//creating graph based on simgrid types
	NSEnumerator *en;
	id host, link;
	id platformType = [self entityTypeWithName: @"platform"];
	id hostType = [self entityTypeWithName: @"HOST"];
	id linkType = [self entityTypeWithName: @"LINK"];
	id platformContainer = [self containerWithName: @"simgrid-platform"
						  type: platformType];

	if (!platformType || !hostType){
		NSLog (@"%s:%d: types (platform=%@, host=%@) not defined",
			__FUNCTION__, __LINE__, platformType, hostType);
		return;
	}
	if (!platformContainer){
		NSLog (@"%s:%d: simgrid-platform container not created",
			__FUNCTION__, __LINE__);
		return;
	}

	if (!hostType){
		return;
	}

	agnodeattr (platformGraph, (char*)"label", (char*)"");
	agraphattr (platformGraph, (char*)"overlap", (char*)"false");
	agraphattr (platformGraph, (char*)"splines", (char*)"true");

	// create graphviz nodes based on hosts container
	en = [self enumeratorOfContainersTyped: hostType
				   inContainer: platformContainer];
	while ((host = [en nextObject])){
		//create graphviz node
		agnode (platformGraph, (char *)[[host name] cString]);

		//create TrivaGraphNode, with name, and keep it in nodes array
		TrivaGraphNode *node = [[TrivaGraphNode alloc] init];
		[node setName: [host name]];
		[nodes addObject: node];
		[node release];
	}

	if (!linkType){
		return;
	}

	// create graphviz edges based on links containers
	en = [self enumeratorOfContainersTyped: linkType
				   inContainer: platformContainer];
	while ((link = [en nextObject])){
		if ([[link name] isEqualToString: @"loopback"])continue;//ignore

		//find src and destination from paje event
		const char *src = [[link valueOfFieldNamed: @"SrcHost"]cString];
		const char *dst = [[link valueOfFieldNamed: @"DstHost"]cString];

		//find graphviz nodes corresponding to this link
		Agnode_t *s = agfindnode (platformGraph, (char*)src);
		Agnode_t *d = agfindnode (platformGraph, (char*)dst);

		if (!s || !d) continue; //ignore if there is no src or dst

		//create the graphviz edge
		agedge (platformGraph, s, d);

		//create the TrivaGraphEdge, with name, put it in edges array
		TrivaGraphEdge *edge = [[TrivaGraphEdge alloc] init];
		[edge setName: [link name]];
		[edge setSource:
			[self findNodeByName:
				[link valueOfFieldNamed: @"SrcHost"]]];
		[edge setDestination: 
			[self findNodeByName:
				[link valueOfFieldNamed: @"DstHost"]]];
		[edges addObject: edge];
		[edge release];
	}

	NSLog (@"%s:%d Executing GraphViz Layout... (this might take a while)",
			__FUNCTION__, __LINE__);
	gvFreeLayout (gvc, platformGraph);
	gvLayout (gvc, platformGraph, (char*)"neato");
	NSLog (@"%s:%d GraphViz Layout done", __FUNCTION__, __LINE__);
//	gvRenderFilename (gvc, platformGraph, (char*)"png", (char*)"out.png");
}

// notifications from previous components
- (void) entitySelectionChanged
{
	[self createSimGridPlatformGraph];
	[self timeSelectionChanged];
}

- (void) containerSelectionChanged
{
	[self createSimGridPlatformGraph];
	[self timeSelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
	[self createSimGridPlatformGraph];
	[self timeSelectionChanged];
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
}

- (void) hierarchyChanged
{
	[self createSimGridPlatformGraph];
	[self timeSelectionChanged];
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
	ret.size.width = GD_bb(platformGraph).UR.x;
	ret.size.height = GD_bb(platformGraph).UR.y;
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
