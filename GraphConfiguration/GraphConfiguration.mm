#include "GraphConfiguration.h"
#include "GraphConfWindow.h"

#define MAX_NODE_SIZE   50
#define MAX_EDGE_SIZE   25

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

	configuration = nil;
	gvc = gvContext();
	graph = NULL;
	nodes = nil;
	edges = nil;

	return self;
}

- (void) dealloc
{
	[configuration release];
	[super dealloc];
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
	NSLog (@"%@ %s", self, __FUNCTION__);
	[self createGraph];
	[self timeSelectionChanged];
}

- (void) setConfiguration: (NSDictionary *) conf
{
	if (configuration){
		[configuration release];
	}
	configuration = conf;
	[configuration retain];

	[self hierarchyChanged];
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

- (void) createGraph
{
	if (!configuration){
		NSLog (@"configuration not created");
		return;
	}

	if (graph){
		agclose (graph);
		[nodes release];
		[edges release];
		graph = NULL;
	}
	graph = agopen ((char *)"graph", AGRAPHSTRICT);
	nodes = [[NSMutableArray alloc] init];
	edges = [[NSMutableArray alloc] init];

	agnodeattr (graph, (char*)"label", (char*)"");
	agraphattr (graph, (char*)"overlap", (char*)"false");
	agraphattr (graph, (char*)"splines", (char*)"true");

	NSMutableArray *nodeTypes = [NSMutableArray array];
	NSMutableArray *edgeTypes = [NSMutableArray array];
	NSEnumerator *en, *en2;
	NSString *typeName;
	PajeEntityType *type;
	id n;

	//TODO:all nodes and edges containers must be children of root (for now)
	id root;
	NSString *rootConf = [configuration objectForKey: @"root"];
	if (rootConf){
		id rootType = [self entityTypeWithName: rootConf];
		en = [self enumeratorOfContainersTyped: rootType
				inContainer: [self rootInstance]];
		root = [en nextObject];
	}else{
		root = [self rootInstance];
	}

	//node related
	en = [[configuration objectForKey: @"node-container"] objectEnumerator];
	while ((typeName = [en nextObject])){
		[nodeTypes addObject:
			[self entityTypeWithName: typeName]];
	}
	en = [nodeTypes objectEnumerator];
	while ((type = [en nextObject])){
		en2 = [self enumeratorOfContainersTyped: type
			inContainer: root];
		while ((n = [en2 nextObject])){
			agnode (graph, (char*)[[n name] cString]);
			TrivaGraphNode *node = [[TrivaGraphNode alloc] init];
			[node setName: [n name]];
			[nodes addObject: node];
			[node release];
		}
	}

	//edge related
	en = [[configuration objectForKey: @"edge-container"] objectEnumerator];
	while ((typeName = [en nextObject])){
		[edgeTypes addObject:
			[self entityTypeWithName: typeName]];
	}
	en = [edgeTypes objectEnumerator];
	while ((type = [en nextObject])){
		if ([type isKindOfClass: [PajeLinkType class]]){
			en2 = [self enumeratorOfEntitiesTyped: type
				inContainer: root
				fromTime: [self startTime]
				toTime: [self endTime]
				minDuration: 0];
		}else if ([type isKindOfClass: [PajeContainerType class]]){
			en2 = [self enumeratorOfContainersTyped: type
				inContainer: root];
		}
		while ((n = [en2 nextObject])){
			const char *src, *dst;
			if ([type isKindOfClass: [PajeLinkType class]]){
				src = [[[n sourceContainer] name] cString];
				dst = [[[n destContainer] name] cString];
			}else if ([type isKindOfClass:
					[PajeContainerType class]]){
				NSString *fsrc, *fdst;
				fsrc = [configuration objectForKey:
						@"edge-src"];
				fdst = [configuration objectForKey:
						@"edge-dst"];
				src = [[n valueOfFieldNamed: fsrc] cString];
				dst = [[n valueOfFieldNamed: fdst] cString];
			}

			Agnode_t *s = agfindnode (graph, (char*)src);
			Agnode_t *d = agfindnode (graph, (char*)dst);
	
			if (!s || !d) continue; //ignore if there is no src/dst
			
			agedge (graph, s, d);

			TrivaGraphEdge *edge = [[TrivaGraphEdge alloc] init];
			[edge setName: [n name]];
			[edge setSource:
				[self findNodeByName:
					[NSString stringWithFormat:@"%s",src]]];
			[edge setDestination:
				[self findNodeByName:
					[NSString stringWithFormat:@"%s",dst]]];
			[edges addObject: edge];
			[edge release];
		}
	}

	NSLog (@"%s:%d Executing GraphViz Layout... (this might take a while)",
			__FUNCTION__, __LINE__);
	NSString *algo = [configuration objectForKey: @"graphviz-algorithm"];
	gvFreeLayout (gvc, graph);
	if (algo){
		gvLayout (gvc, graph, (char*)[algo cString]);
	}else{
		gvLayout (gvc, graph, (char*)"neato");
	}
	NSLog (@"%s:%d GraphViz Layout done", __FUNCTION__, __LINE__);
}

- (double) evaluateWithValues: (NSDictionary *) values
		withExpr: (NSString *) expr
{
	NSMutableString *size_def = [NSMutableString stringWithString: expr];
	int number = 0;
	if (values){
		NSEnumerator *en2 = [values keyEnumerator];
		NSString *val;
		while ((val = [en2 nextObject])){
			NSString *repl = [NSString stringWithFormat: @"%@",
				[values objectForKey: val]];
			number += [size_def replaceOccurrencesOfString: val
				withString: repl
				options: NSLiteralSearch
				range: NSMakeRange(0, [size_def length])];
		}
	}

	//math eval to define size
	char **names;
	int count;
	void *f = evaluator_create ((char*)[size_def cString]);
	evaluator_get_variables (f, &names, &count);
	if (count != 0){
//		NSLog (@"%s:%d Expression (%@) has variables that are "
//			"not present in the aggregated tree. Considering "
//			"that their values is zero.",
//			__FUNCTION__, __LINE__, size_def);
		int i;
		double *zeros = (double*)malloc(count*sizeof(double));
		for (i = 0; i < count; i++){
			zeros[i] = 0;
		}
		double ret = evaluator_evaluate (f, count, names, zeros);
		evaluator_destroy (f);
		return ret;
	}else{
		if (!number){
			return -1; /* to indicate that is a numeric value */
		}
		double ret = evaluator_evaluate (f, 0, NULL, NULL);
		evaluator_destroy (f);
		return ret;
	}
}

- (double) calculateScreenSizeBasedOnValue: (double) size
	andMax: (double)max andMin: (double)min
{
	double s = 0;
	if ((max - min) != 0) {
		s = MAX_NODE_SIZE * (size) /
			(max - min);
	}else{
		s = MAX_NODE_SIZE * (size) /(max);
	}
	return s;
}

- (void) defineMax: (double*) max
	andMin: (double*) min
	withConfigurationKey: (NSString *) confKey
	fromEnumerator: (NSEnumerator*) en
{
	*max = 0;
	*min = FLT_MAX;
	TimeSliceTree *tree;
	id obj;
	while ((obj = [en nextObject])){
		tree = [[self timeSliceTree] searchChildByName: [obj name]];
		if (tree == nil){
//			NSLog (@"%s:%d time slice tree for obj %@ not found",
//				__FUNCTION__, __LINE__, [obj name]);
			continue;
		}
		NSString *expr = [configuration objectForKey: confKey];
		double size = [self evaluateWithValues: [tree aggregatedValues]
					withExpr: expr];
		if (size > 0){
			if (size > *max) *max = size;
			if (size < *min) *min = size;
		}
	}
}

- (NSDictionary*) redefineColorFrom: (NSDictionary*) values
		withConfiguration: (NSArray*) colConfiguration
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	NSEnumerator *en = [colConfiguration objectEnumerator];
	NSString *expr;
	while ((expr = [en nextObject])){
		double val = [self evaluateWithValues: values
				withExpr: expr];
		if (val > 0){
			[ret setObject: [NSNumber numberWithDouble: 1]
					forKey: expr];
			//only the first expression found
			return ret;
		}
	}
	return nil;
}

- (NSDictionary*) redefineSeparationValuesWith: (NSDictionary*) values
		andConfiguration: (NSArray*) sepConfiguration
		andSize: (double) size
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	NSEnumerator *en = [sepConfiguration objectEnumerator];
	NSString *expr;
	while ((expr = [en nextObject])){
		double val = [self evaluateWithValues: values
				withExpr: expr];
		if (val > 0){
			[ret setObject: [NSNumber numberWithDouble: val/size]
					forKey: expr];
		}
	}
	return ret;
}

- (void) redefineLayoutOf: (TrivaGraphNode*) obj withStr: str
		withMax: (double)max withMin: (double)min
{
	TimeSliceTree *tree;
	NSMutableDictionary *values;

	NSString *objsize = [NSString stringWithFormat: @"%@-size", str];
	NSString *objsep = [NSString stringWithFormat: @"%@-separation", str];
	NSString *objgra = [NSString stringWithFormat: @"%@-gradient", str];
	NSString *objcol = [NSString stringWithFormat: @"%@-color", str];

	tree = [[self timeSliceTree] searchChildByName: [obj name]];
	if (tree == nil){
		/* NOTE: only falls here if edge is of link type.
			the width attribute is necessary to drawing. */
		NSString *expr = [configuration objectForKey: objsize];
		double screenSize;
		double size = [self evaluateWithValues: nil withExpr: expr];
		if (size < 0){
			screenSize = [expr doubleValue];
		}else{
			screenSize = [self calculateScreenSizeBasedOnValue: size
				andMax: max andMin: min];
		}
		NSRect rect;
		rect.size.width = screenSize;
		rect.size.height = screenSize;
		[obj setSize: rect];
		[obj setDrawable: YES];
		return;
	}
	values = [NSMutableDictionary dictionaryWithDictionary:
		[tree aggregatedValues]];
	Agnode_t *n = agfindnode (graph,
		(char *)[[obj name] cString]);
	NSPoint objPos;
	objPos.x = 0;
	objPos.y = 0;
	if (n){
		objPos.x = ND_coord_i(n).x;
		objPos.y = ND_coord_i(n).y;
		[obj setPosition: objPos];
	}
	NSRect objRect;
	objRect.origin.x = objPos.x;
	objRect.origin.y = objPos.y;
	NSString *expr = [configuration objectForKey: objsize];
	double screenSize;
	double size = [self evaluateWithValues: values withExpr: expr];
	if (size < 0){
		screenSize = [expr doubleValue];
	}else{
		screenSize = [self calculateScreenSizeBasedOnValue: size
			andMax: max andMin: min];
	}
	objRect.size.width = screenSize;
	objRect.size.height = screenSize;
	[obj setSize: objRect];

	id sepConfiguration = [configuration objectForKey: objsep];
	id graConfiguration = [configuration objectForKey: objgra];
	id colConfiguration = [configuration objectForKey: objcol];
	if (sepConfiguration){
		NSDictionary *separationValues;
		separationValues = [self redefineSeparationValuesWith: values
					andConfiguration: sepConfiguration
					andSize: size];
		[obj setValues: separationValues];
		[obj setSeparation: YES];
		[obj setDrawable: YES];
	}
	if(colConfiguration && [obj separation] == NO){
		// there is a color configuration and sepValues were not defined
		NSDictionary *separationValues;
		separationValues = [self redefineColorFrom: values
					withConfiguration: colConfiguration];
		if (separationValues){
			[obj setValues: separationValues];
			[obj setColor: YES];
			[obj setDrawable: YES];
		}
	}
	if(graConfiguration && [obj separation] == NO && [obj color] == NO ){
		if ([graConfiguration count] >= 1){
			double val, max, min;
			val = [self evaluateWithValues: values
				 withExpr: [graConfiguration objectAtIndex: 0]];
			max = [self evaluateWithValues: 
			 	[[self timeSliceTree] maxValues]
				 withExpr: [graConfiguration objectAtIndex: 0]];
			min = [self evaluateWithValues: 
					[[self timeSliceTree] minValues]
				withExpr: [graConfiguration objectAtIndex: 0]];

			[obj setGradientType: [graConfiguration objectAtIndex:0]
				withValue: val withMax: max withMin: min];
			[obj setGradient: YES];
			[obj setDrawable: YES];
		}
		
	}
}


- (void) redefineNodesEdgesLayout
{
	if (!graph){
		NSLog (@"%s:%d: platform graph not created",
			__FUNCTION__, __LINE__);
		return;
	}
	
	[self defineMax: &maxNode andMin: &minNode
		withConfigurationKey: @"node-size"
		fromEnumerator: [self enumeratorOfNodes]];
	
	NSEnumerator *en = [self enumeratorOfNodes];
	TrivaGraphNode *node;
	while ((node = [en nextObject])){
		[self redefineLayoutOf: node withStr: @"node"
			withMax: maxNode withMin: minNode];
	}
	[self defineMax: &maxEdge andMin: &minEdge
		withConfigurationKey: @"edge-size"
		fromEnumerator: [self enumeratorOfEdges]];
	en = [self enumeratorOfEdges];
	TrivaGraphEdge *edge;
	while ((edge = [en nextObject])){
		[self redefineLayoutOf: edge withStr: @"edge"
			withMax: maxEdge withMin: minEdge];
	}
}
@end
