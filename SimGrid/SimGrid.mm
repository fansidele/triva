#include "SimGrid.h"

//conversion functions so we can deal with graphviz
//properly (it expects inches for sizes, generally)
#define PTOI(pixel) ((double)(pixel/96))
#define ITOP(inch)  ((double)(inch*96))

//following values should be in pixels
#define DEFAULT_SIZE	2
#define ROUTER_SIZE	10
#define MIN_HOST_SIZE	20
#define MAX_HOST_SIZE	50
#define MIN_LINK_SIZE	10
#define MAX_LINK_SIZE	50

//
#define AGSETLINKSIZE(n,val) \
{ \
char str_what_val[100]; \
snprintf (str_what_val,100,"setlinewidth(%d)",(int)val); \
agsafeset(n,(char*)"style", str_what_val, str_what_val); \
}

#define AGSET(n,width,height) \
{ \
char str_width[100]; \
char str_height[100]; \
char default_size[100]; \
snprintf (str_width, 100, "%f", PTOI(width)); \
snprintf (str_height, 100, "%f", PTOI(height)); \
snprintf (default_size, 100, "%f", PTOI(DEFAULT_SIZE)); \
agsafeset (n, (char*)"width", str_width, default_size); \
agsafeset (n, (char*)"height", str_height, default_size); \
}

#define AGGET(n,par) (atof(agget(n,(char*)par)))

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
	sizes = nil;
	return self;
}

- (void) dealloc
{
	gvFreeContext (gvc);
	agclose (platformGraph);
	[nodes release];
	[edges release];
	[sizes release];
	[super dealloc];
}

- (void) settingGraphvizLayoutAttributes
{
	if (!platformGraph){
		NSLog (@"%s:%d: platform graph not created",
			__FUNCTION__, __LINE__);
		return;
	}

	agnodeattr (platformGraph, (char*)"label", (char*)"");
	agraphattr (platformGraph, (char*)"overlap", (char*)"false");
	agraphattr (platformGraph, (char*)"splines", (char*)"true");

	TrivaGraphEdge *edge;
	TrivaGraphNode *node;
	NSEnumerator *en;

	//for all nodes, set graphviz attributes such as shape/width/height
	// shape is rectangle
	// width/height = area is related to the power attribute
	en = [nodes objectEnumerator];
	while ((node = [en nextObject])){
		//find the existing graphviz node
		Agnode_t *n = agfindnode (platformGraph,
				(char *)[[node name] cString]);

		//set its shape: if rectangle == overlap
		agsafeset (n, (char*)"shape", (char*)"rectangle",
			(char*)"rectangle");

		//find the power to this node
		double power = [[sizes objectForKey: node] doubleValue];

		//calculate width/height values based on power
		if (power == 0) { //is a router
			AGSET(n, ROUTER_SIZE, ROUTER_SIZE);
		}else{
			double s = 0;
			s += MIN_HOST_SIZE;
			s += MAX_HOST_SIZE*
				(power - minPower)/(maxPower - minPower);
//			NSLog (@"%s %f", n->name, s);
//			NSLog (@"\tp=%f min=%f max=%f dif=%f",
//				power, minPower, maxPower, maxPower-minPower);
			AGSET(n, s, s);
		}
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
		double size = 0;
		size += MIN_LINK_SIZE;
		size += MAX_LINK_SIZE *
			(bw - minBandwidth) / (maxBandwidth - minBandwidth);
		AGSET(e, size, size);
//		AGSETLINKSIZE(e,size);
	}
}

- (void) doGraphvizLayout
{
	NSLog (@"%s:%d Executing GraphViz Layout... (this might take a while)",
			__FUNCTION__, __LINE__);
	gvFreeLayout (gvc, platformGraph);
	gvLayout (gvc, platformGraph, (char*)"neato");
	NSLog (@"%s:%d GraphViz Layout done", __FUNCTION__, __LINE__);
//	gvRenderFilename (gvc, platformGraph, (char*)"dot", (char*)"out.dot");
}

- (void) redefinePlatformGraphLayout
{
	if (!platformGraph){
		NSLog (@"%s:%d: platform graph not created",
			__FUNCTION__, __LINE__);
		return;
	}
	double time_interval;
	time_interval = [[self selectionEndTime]
		timeIntervalSinceDate: [self selectionStartTime]];

	//take graphviz information (node position mainly)
	//and prepare each TrivaGraphNode node/edge to be draw by next component
	//this preparation means size/position are defined with NSRect/NSPoint	
	// NSRect/NSPoint values should always be in pixels
	//
	//    AND
	//
	//use timeSlice aggregated values to split the space of each node
	//this should also be a parameter of the user
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
		nodeRect.size.width = ITOP(AGGET(n,"width"));
		nodeRect.size.height = ITOP(AGGET(n,"height"));
		[node setSize: nodeRect];

		//since we have point and size for this node, we can say
		//it is already drawable
		[node setDrawable: YES];

		//aggregated values TODO: is this generic?
		//this should be defined by the user
		TimeSliceTree *tree;
		NSMutableDictionary *nodeGraphValues;
		nodeGraphValues = [NSMutableDictionary dictionary];
		NSDictionary *values;
		tree = [[self timeSliceTree] searchChildByName: [node name]];
		values = [tree aggregatedValues];

		id key;
		NSEnumerator *en2 = [values keyEnumerator];
		while ((key = [en2 nextObject])){
			double val, power;
			val = [[values objectForKey: key] doubleValue];
			power = [[sizes objectForKey: node] doubleValue];

			if (power != 0 && val != 0){	
				[nodeGraphValues setObject:
					[NSNumber numberWithDouble:
					     val/(power*time_interval)]
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
		edgeRect.size.width = AGGET(e,"width");
		edgeRect.size.height = AGGET(e, "height"); //what for?
		[edge setSize: edgeRect];

		//since we have the width of the link, we can say
		//it is already drawable
		[edge setDrawable: YES];

		//COPIED FROM ABOVE aggregated values TODO: is this generic?
		//this should be defined by the user
		TimeSliceTree *tree;
		NSMutableDictionary *edgeSeparationValues;
		edgeSeparationValues = [NSMutableDictionary dictionary];
		NSDictionary *values;
		tree = [[self timeSliceTree] searchChildByName: [edge name]];
		values = [tree aggregatedValues];

		NSEnumerator *en2 = [values keyEnumerator];
		id key;
//		NSLog (@"%@ - %@", [edge name], values);
		while ((key = [en2 nextObject])){
			double val, linkBandwidth;
			val = [[values objectForKey: key] doubleValue];
			linkBandwidth = [[sizes objectForKey:edge] doubleValue];

//			NSLog (@"\t%@ val = %.3f link = %.3f interval = %.3f calc = %.3f",
//				key, val, linkBandwidth, time_interval,
//					val/(linkBandwidth*time_interval));
			if (linkBandwidth != 0 && val != 0){	
				[edgeSeparationValues setObject:
					[NSNumber numberWithDouble:
					     val/(linkBandwidth*time_interval)]
						    forKey: key];
			}
		}
		[edge setValues: edgeSeparationValues];
	}
}

- (void) createPlatformGraph
{
	//close before starting a new one
	if (platformGraph){
		[nodes release];
		[edges release];
		[sizes release];
		agclose (platformGraph); 
		platformGraph = NULL;
	}
	platformGraph = agopen ((char *)"platformGraph", AGRAPHSTRICT);
	nodes = [[NSMutableArray alloc] init];
	edges = [[NSMutableArray alloc] init];
	sizes = [[NSMutableDictionary alloc] init];

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

	// create graphviz nodes based on hosts, define size, max, min power
	maxPower = 0;
	minPower = FLT_MAX;
	en = [self enumeratorOfContainersTyped: hostType
				   inContainer: platformContainer];
	while ((host = [en nextObject])){
		//create graphviz node
		agnode (platformGraph, (char *)[[host name] cString]);

		//find its power
		double power = [[host valueOfFieldNamed: @"Power"] doubleValue];

		//define max min power
		if (power != 0){
			if (power > maxPower) maxPower = power;
			if (power < minPower) minPower = power;
		}

		//create TrivaGraphNode, with name, and keep it in nodes array
		TrivaGraphNode *node = [[TrivaGraphNode alloc] init];
		[node setName: [host name]];
		[nodes addObject: node];

		//define the size of the host in sizes dict
		[sizes setObject: [NSNumber numberWithDouble: power]
			  forKey: node];
		[node release];
	}

	if (!linkType){
		return;
	}

	// create graphviz edges based on links, define size, max, min bw
	maxBandwidth = 0;
	minBandwidth = FLT_MAX;
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

		//find the bandwidth for this link
		double bw = [[link valueOfFieldNamed: @"Bandwidth"]doubleValue];

		//define max, min bandwidth
		if (bw < minBandwidth) minBandwidth = bw;
		if (bw > maxBandwidth) maxBandwidth = bw;

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

		//define the size of this link in sizes dict
		[sizes setObject: [NSNumber numberWithDouble: bw]
			  forKey: edge];
		[edge release];
	}

	//report max, min for hosts/links
	//NSLog (@"\nReport of max/min values for hosts/links:\n"
	//	"\t Power [%f,%f] dif=%f\n"
	//	"\t Bandwidth [%f,%f] dif=%f",
	//		minPower, maxPower, maxPower-minPower,
	//		minBandwidth, maxBandwidth, maxBandwidth-minBandwidth);


	//setting requirements:
	//	node size is related to what*
	//	link size is related to what*
	//*for now, it is related to fixed attributes (power, bandwidth)
	//but it should be decided by the user
	[self settingGraphvizLayoutAttributes];

	//run graphviz layout function
	[self doGraphvizLayout];
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
	[self createPlatformGraph];
	[self timeSelectionChanged];
}

- (void) containerSelectionChanged
{
	[self createPlatformGraph];
	[self timeSelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
	[self createPlatformGraph];
	[self timeSelectionChanged];
}

- (void) timeSelectionChanged
{
	static int first_time = 1;
	if (first_time){
		first_time = 0;
	}else{
		[self redefinePlatformGraphLayout];
		[super timeSelectionChanged];
	}
}

- (void) hierarchyChanged
{
	[self createPlatformGraph];
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
