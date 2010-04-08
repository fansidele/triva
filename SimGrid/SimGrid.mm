#include "SimGrid.h"

#define ROUTER_SIZE 0.1
#define MIN_HOST_SIZE 0.3
#define MIN_LINK_SIZE 0.01

@implementation SimGrid
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	platformCreated = NO;
	nodes = [[NSMutableArray alloc] init];
	edges = [[NSMutableArray alloc] init];
	sizes = [[NSMutableDictionary alloc] init];
	return self;
}

- (void) graphvizAttributes
{
	agnodeattr (platformGraph, (char*)"label", (char*)"");

	TrivaGraphEdge *edge;
	TrivaGraphNode *node;
	NSEnumerator *en;

	// find min and max power
	double maxPower = 0, minPower = FLT_MAX;
	en = [nodes objectEnumerator];
	while ((node = [en nextObject])){
		double power = [[sizes objectForKey: node] doubleValue];
		if (power == 0) continue; //ignore router power
		if (power > maxPower) maxPower = power;
		if (power < minPower) minPower = power;
	}

	// find min and max bw
	double maxBw = 0, minBw = FLT_MAX;
	en = [edges objectEnumerator];
	while ((edge = [en nextObject])){
		if ([[edge name] isEqualToString: @"loopback"]) continue;
		double bw = [[sizes objectForKey: edge] doubleValue];
		if (bw < minBw) minBw = bw;
		if (bw > maxBw) maxBw = bw;
	}

	en = [nodes objectEnumerator];
	while ((node = [en nextObject])){
		//graphviz-related
		Agnode_t *n = agfindnode (platformGraph,
				(char *)[[node name] cString]);
		agsafeset (n, (char*)"shape", (char*)"rectangle",
			(char*)"rectangle");
		double power = [[sizes objectForKey: node] doubleValue];

		char sizestr[100];
		if (power == 0){ //define router size
			double size = ROUTER_SIZE;
			snprintf (sizestr, 100, "%g", size);
		}else{
			double size = MIN_HOST_SIZE + (power - minPower)/(maxPower - minPower);
			snprintf (sizestr, 100, "%g", size);
		}
		agsafeset (n, (char*)"width", sizestr, (char*)"1");
		agsafeset (n, (char*)"height", sizestr, (char*)"1");
	}

	en = [edges objectEnumerator];
	while ((edge = [en nextObject])){
		TrivaGraphNode *src = [edge source];
		TrivaGraphNode *dst = [edge destination];
		Agnode_t *s, *d;
		s = agfindnode (platformGraph, (char*)[[src name] cString]);
		d = agfindnode (platformGraph, (char*)[[dst name] cString]);

                Agedge_t *e = agfindedge (platformGraph, s, d);
		double bw = [[sizes objectForKey: edge] doubleValue];
		double size = MIN_LINK_SIZE + (bw - minBw)/(maxBw - minBw);
		char ns[100], nss[100];
		snprintf (ns, 100, "setlinewidth(%d)", (int)(5+10*size)); //just for calculating node separation
		snprintf (nss, 100, "%f", size);
		agsafeset (e, (char*)"style", (char*)ns, (char*)"setlinewidth(10)");
		agsafeset (e, (char*)"bandwidth", (char*)nss, (char*)nss);
	}
}

- (void) graphvizLayout
{
	gvFreeLayout (gvc, platformGraph);
	gvLayout (gvc, platformGraph, (char*)"neato");
//	gvRenderFilename (gvc, platformGraph, (char*)"png", (char*)"out.png");
}

- (void) redefinePlatformGraphLayout
{
	if (!platformGraph){
		NSLog (@"%s:%d: platform graph not created",
			__FUNCTION__, __LINE__);
		return;
	}
	[self graphvizAttributes];
	[self graphvizLayout];

	NSEnumerator *en = [nodes objectEnumerator];
	TrivaGraphNode *node;
	while ((node = [en nextObject])){
		Agnode_t *n = agfindnode (platformGraph,
				(char *)[[node name] cString]);
		NSPoint nodePos;
		nodePos.x = ND_coord_i(n).x;
		nodePos.y = ND_coord_i(n).y;
		[node setPosition: nodePos];

		NSRect nodeRect;
		nodeRect.origin.x = nodePos.x;
		nodeRect.origin.y = nodePos.y;
		nodeRect.size.width = atof(agget (n, (char*)"width")); //inch
		nodeRect.size.height = atof(agget (n, (char*)"height")); //inch
		[node setSize: nodeRect];

		//aggregated values TODO: is this generic?
		TimeSliceTree *tree;
		NSMutableDictionary *nodeGraphValues;
		nodeGraphValues = [NSMutableDictionary dictionary];
		NSDictionary *values, *durations;
		tree = [[self timeSliceTree] searchChildByName: [node name]];
		values = [tree aggregatedValues];
		durations = [tree timeSliceDurations];

		NSEnumerator *en2;
		id key;
		en2 = [values keyEnumerator];
		int existing = 0;
		while ((key = [en2 nextObject])){
			if([[values objectForKey: key] doubleValue]) existing++;
		}

		en2 = [values keyEnumerator];
		while ((key = [en2 nextObject])){
			double duration, val, size;
			duration = [[durations objectForKey: key] doubleValue];
			val = [[values objectForKey: key] doubleValue];
			size = [[sizes objectForKey: node] doubleValue];
	
			if (duration) {
				[nodeGraphValues setObject:
					[NSNumber numberWithDouble:
					     val/(existing*size*duration)]
						    forKey: key];
			}
		}
		[node setValues: nodeGraphValues];
	}

	en = [edges objectEnumerator];
	TrivaGraphEdge *edge;
	while ((edge = [en nextObject])){
		TrivaGraphNode *src = [edge source];
		TrivaGraphNode *dst = [edge destination];
		Agnode_t *s, *d;
		s = agfindnode (platformGraph, (char*)[[src name] cString]);
		d = agfindnode (platformGraph, (char*)[[dst name] cString]);

                Agedge_t *e = agfindedge (platformGraph, s, d);
		NSRect edgeRect;
		edgeRect.size.width = atof(agget (e, (char*)"bandwidth"));
		[edge setSize: edgeRect];

		//COPIED FROM ABOVE aggregated values TODO: is this generic?
		TimeSliceTree *tree;
		NSMutableDictionary *nodeGraphValues;
		nodeGraphValues = [NSMutableDictionary dictionary];
		NSDictionary *values, *durations;
		tree = [[self timeSliceTree] searchChildByName: [edge name]];
		values = [tree aggregatedValues];
		durations = [tree timeSliceDurations];

		NSEnumerator *en2;
		id key;
		en2 = [values keyEnumerator];
		int existing = 0;
		while ((key = [en2 nextObject])){
			if([[values objectForKey: key] doubleValue]) existing++;
		}

		en2 = [values keyEnumerator];
		while ((key = [en2 nextObject])){
			double duration, val, size;
			duration = [[durations objectForKey: key] doubleValue];
			val = [[values objectForKey: key] doubleValue];
			size = [[sizes objectForKey: edge] doubleValue];
	
			if (duration) {
				[nodeGraphValues setObject:
					[NSNumber numberWithDouble:
					     val/(existing*size*duration)]
						    forKey: key];
			}
		}
		[edge setValues: nodeGraphValues];
	}
}

- (void) createPlatformGraph
{
	static int flag = 1;
	if (flag){
		gvc = gvContext();
		flag = 0;
	}
	//close before starting a new one
	if (platformGraph) {
		[nodes release];
		[edges release];
		[sizes release];
		nodes = [[NSMutableArray alloc] init];
		edges = [[NSMutableArray alloc] init];
		sizes = [[NSMutableDictionary alloc] init];
		agclose (platformGraph); 
	}
	platformGraph = agopen ((char *)"platformGraph", AGRAPHSTRICT);

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

	// create graphviz nodes based on hosts, define size
	en = [self enumeratorOfContainersTyped: hostType
				   inContainer: platformContainer];
	while ((host = [en nextObject])){
		agnode (platformGraph, (char *)[[host name] cString]);
		double power = [[host valueOfFieldNamed: @"Power"] doubleValue];

		TrivaGraphNode *node = [[TrivaGraphNode alloc] init];
		[node setName: [host name]];
		[nodes addObject: node];

		[sizes setObject: [NSNumber numberWithDouble: power]
			  forKey: node];
		[node release];
	}

	if (!linkType){
		return;
	}

	// create graphviz edges based on links, define size
	en = [self enumeratorOfContainersTyped: linkType
				   inContainer: platformContainer];
	while ((link = [en nextObject])){
		if ([[link name] isEqualToString: @"loopback"])continue;//ignore
		const char *src = [[link valueOfFieldNamed: @"SrcHost"]cString];
		const char *dst = [[link valueOfFieldNamed: @"DstHost"]cString];
		Agnode_t *s = agfindnode (platformGraph, (char*)src);
		Agnode_t *d = agfindnode (platformGraph, (char*)dst);
		if (!s || !d) continue; //ignore if there is no src or dst
		agedge (platformGraph, s, d);
		double bw = [[link valueOfFieldNamed: @"Bandwidth"]doubleValue];

		TrivaGraphEdge *edge = [[TrivaGraphEdge alloc] init];
		[edge setName: [link name]];
		[edge setSource:
			[self findNodeByName:
				[link valueOfFieldNamed: @"SrcHost"]]];
		[edge setDestination: 
			[self findNodeByName:
				[link valueOfFieldNamed: @"DstHost"]]];
		[edges addObject: edge];

		[sizes setObject: [NSNumber numberWithDouble: bw]
			  forKey: edge];
		[edge release];
	}
	platformCreated = YES;
}


/* OLD COMM
- (NSPoint) getInteractivePositionForHost: (id) host
{
	if (![host isKindOfClass: [NSString class]]){
		host = [host name];
	}	
	NSPoint ret;
	Agnode_t *node = agfindnode (platformGraph, (char*)[host cString]);
	char *x = agget (node, (char*)"xtriva");
	char *y = agget (node, (char*)"ytriva");
	if (x && y){
		ret.x = atof (x);
		ret.y = atof (y);
	}else{
		ret = [self getPositionForHost: host];
	}
	return ret;
}
*/

/* OLD COMM
- (void) setInteractivePositionForHost: (id) host toPoint: (NSPoint) p
{
	NSLog (@"setting %@ for %f,%f", host, p.x, p.y);
	Agnode_t *node = agnode (platformGraph, (char *)[[host name] cString]);

	char xstr[100], ystr[100];
	snprintf (xstr, 100, "%f", p.x);
	snprintf (ystr, 100, "%f", p.y);
	agsafeset (node, (char*)"xtriva", xstr, xstr);
	agsafeset (node, (char*)"ytriva", ystr, ystr);
}
*/

/*
// power & bandwidth utilization 
- (NSDictionary *) getUtilization: (NSString *) field
		     forContainer: (id) container
			withMaxValue: (NSString *) maxField
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	NSEnumerator *en, *en2;
	id type;
 	en = [[self containedTypesForContainerType: [container entityType]] objectEnumerator];
	double containerFieldValue = [[container valueOfFieldNamed: maxField] doubleValue];
	double accum_time = 0;
	NSMutableSet *intervals = [NSMutableSet set];
	while ((type = [en nextObject])){
		id what;
		en2 = [self enumeratorOfEntitiesTyped: type
                                                inContainer: container
                                                fromTime: [self selectionStartTime]
                                                toTime: [self selectionEndTime]
                                                minDuration: 0];
		double type_val = 0;
		while ((what = [en2 nextObject])){
			double start = [[[what startTime] description] doubleValue];
			double end = [[[what endTime] description] doubleValue];
			double value = [[what valueOfFieldNamed: field] doubleValue];
			if ((end-start)!=0){
				type_val += (value * (end-start));
			}
			NSString *interval = [NSString stringWithFormat: @"%f-%f", start, end];
			if (![intervals containsObject: interval]){
				accum_time += end-start;
				[intervals addObject: interval];
			}
		}
		if (type_val){
			[ret setObject: [NSString stringWithFormat: @"%f", type_val]
				forKey: type];
		}
	}
	en = [[self containedTypesForContainerType: [container entityType]] objectEnumerator];
	while ((type = [en nextObject])){
		if ([ret objectForKey: type]){
			double val = [[ret objectForKey: type] doubleValue];
			val = val/(containerFieldValue*accum_time);
			[ret setObject: [NSString stringWithFormat: @"%f", val]
				forKey: type];
		}
	}
	return ret;
}

// power utilization 
- (NSDictionary *) getPowerUtilizationOfHost: (id) host
{
	NSDictionary *ret;
	ret = [self getUtilization: @"PowerUsed"
		      forContainer: host
		      withMaxValue: @"Power"];
	return ret;
}

// bandwidth utilization 
- (NSDictionary *) getBandwidthUtilizationOfLink: (id) link
{
	NSDictionary *ret;
	ret = [self getUtilization: @"BandwidthUsed"
		      forContainer: link
		      withMaxValue: @"Bandwidth"];
	return ret;
}

*/

// notifications from previous components
- (void) entitySelectionChanged
{
	[self hierarchyChanged];
}

- (void) containerSelectionChanged
{
	[self hierarchyChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
	[self hierarchyChanged];
}

- (void) timeSelectionChanged
{
	[self hierarchyChanged];
}

- (void) hierarchyChanged
{
	[self createPlatformGraph];
	[self redefinePlatformGraphLayout];
	[super hierarchyChanged];
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
