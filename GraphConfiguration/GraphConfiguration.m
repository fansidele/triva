/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GraphConfiguration.h"

#define MAX_SIZE   60

@implementation GraphConfiguration
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
		[NSBundle loadNibNamed: @"GraphConf" owner: self];
	}
	[self initInterface];

	configuration = nil;
	gvc = gvContext();
	graph = NULL;
	nodes = nil;
	edges = nil;

	userPositions = NO;

	return self;
}

- (void) dealloc
{
	[configuration release];
	[configurations release];
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

  NSString *tracefilePath = [[self rootInstance] name];
  NSString *tf = [[tracefilePath componentsSeparatedByString: @"/"] lastObject];
  [window setTitle: [NSString stringWithFormat: @"Triva - %@ - GraphConfig", tf]];
}

- (void) hierarchyChanged
{
	NSLog (@"%@ %s", self, __FUNCTION__);
	[self createGraph];
	[self timeSelectionChanged];
}

- (void) entitySelectionChanged
{
  [self timeSelectionChanged];
}

- (void) containerSelectionChanged
{
  [self timeSelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
  [self timeSelectionChanged];
}

- (void) setConfiguration: (NSDictionary *) c
{
	if (configuration){
		[configuration release];
	}
	configuration = [NSDictionary dictionaryWithDictionary: c];
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
	if (userPositions){
		return graphSize;
	}
  if (graphviz){
		NSRect ret;
		ret.origin.x = ret.origin.y = 0;
		if (graph){
			ret.size.width = GD_bb(graph).UR.x;
			ret.size.height = GD_bb(graph).UR.y;
		}else{
			ret.size.width = 0;
			ret.size.height = 0;
		}
		return ret;
  }else{
    return graphSize;
  }
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

  //check if I should use GraphViz
  if ([configuration objectForKey: @"graphviz"]){
    NSLog (@"Disabling GraphViz");
    graphviz = NO;
  }else{
    graphviz = YES;
  }

	//checking if user provided positions for nodes
	id area = [configuration objectForKey: @"Area"];
	if (!area){
		area = [configuration objectForKey: @"area"];
	}
	if (area){
		graphSize.origin.x = [[area objectForKey: @"x"] doubleValue];
		graphSize.origin.y = [[area objectForKey: @"y"] doubleValue];
		graphSize.size.width = [[area objectForKey: @"width"] doubleValue];
		graphSize.size.height = [[area objectForKey: @"height"] doubleValue];
		userPositions = YES;
	}

	[nodes release];
	[edges release];
	if (userPositions == NO){
		if (graph){
			agclose (graph);
			graph = NULL;
		}
		graph = agopen ((char *)"graph", AGRAPHSTRICT);
        
		agnodeattr (graph, (char*)"label", (char*)"");
		agraphattr (graph, (char*)"overlap", (char*)"false");
		agraphattr (graph, (char*)"splines", (char*)"true");
	}
	nodes = [[NSMutableArray alloc] init];
	edges = [[NSMutableArray alloc] init];

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
	en = [[configuration objectForKey: @"node"] objectEnumerator];
	while ((typeName = [en nextObject])){
		[nodeTypes addObject:
			[self entityTypeWithName: typeName]];
	}
	en = [nodeTypes objectEnumerator];
	while ((type = [en nextObject])){
		en2 = [self enumeratorOfContainersTyped: type
			inContainer: root];
		while ((n = [en2 nextObject])){
			if (userPositions == NO){
				agnode (graph, (char*)[[n name] cString]);
			}
			TrivaGraphNode *node = [[TrivaGraphNode alloc] init];
			[node setName: [n name]];
			[node setType: [type name]];
			[nodes addObject: node];
			[node release];
		}
	}

	//edge related
	en = [[configuration objectForKey: @"edge"] objectEnumerator];
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
				fsrc = [[configuration objectForKey:[type name]]
						objectForKey: @"src"];
				fdst = [[configuration objectForKey:[type name]]
						objectForKey: @"dst"];
				src = [[n valueOfFieldNamed: fsrc] cString];
				dst = [[n valueOfFieldNamed: fdst] cString];
			}

			if (userPositions == NO){
				Agnode_t *s = agfindnode (graph, (char*)src);
				Agnode_t *d = agfindnode (graph, (char*)dst);
	
				if (!s || !d) continue;
					//ignore if there is no src/dst
			
				agedge (graph, s, d);
			}

			TrivaGraphEdge *edge = [[TrivaGraphEdge alloc] init];
			[edge setName: [n name]];
			[edge setType: [type name]];
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

	if (userPositions == NO && graphviz){
		NSLog (@"%s:%d Executing GraphViz Layout... (this might "
			"take a while)", __FUNCTION__, __LINE__);
		NSString *algo;
		algo = [configuration objectForKey: @"graphviz-algorithm"];
		gvFreeLayout (gvc, graph);
		if (algo){
			gvLayout (gvc, graph, (char*)[algo cString]);
		}else{
			gvLayout (gvc, graph, (char*)"neato");
		}
		NSLog (@"%s:%d GraphViz Layout done", __FUNCTION__, __LINE__);
	}
}

- (void) defineMax: (double*)max andMin: (double*)min withScale: (TrivaScale) scale
		fromVariable: (NSString*)var
		ofObject: (NSString*) objName withType: (NSString*) objType
{
	PajeEntityType *valtype = [self entityTypeWithName: var];
	if (scale == Global){
		*min = [self minValueForEntityType: valtype];
		*max = [self maxValueForEntityType: valtype];
	}else{
		//if local scale, *min and *max from this container
		//	container is found based on the name of the obj
		PajeEntityType *type = [self entityTypeWithName: objType]; 
		PajeContainer *cont = [self containerWithName: objName type: type];
		*min = [self minValueForEntityType: valtype inContainer: cont];
		*max = [self maxValueForEntityType: valtype inContainer: cont];
	}
}

- (double) evaluateWithValues: (NSDictionary *) values
		withExpr: (NSString *) expr
{
	if (!expr) return -2;

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
		free (zeros);
		return ret;
	}else{
		if (!number){
			evaluator_destroy (f);
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
		s = MAX_SIZE * (size) /
			(max - min);
	}else{
		s = MAX_SIZE * (size) /(max);
	}
	return s * [self graphComponentScaling];
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

- (double) getVariableOfTypeName: (NSString *)variable
            ofContainerName: (NSString *)cont
{
  PajeEntityType *type = [self entityTypeWithName: variable];
  PajeContainerType *containerType = [self containerTypeForType: type];
  PajeContainer *container = [self containerWithName: cont
                                        type: containerType];
  if (!type) return 0;
  NSEnumerator *en = [self enumeratorOfEntitiesTyped: type
                          inContainer: container
                              fromTime: [self startTime]
                                toTime: [self endTime]
                                  minDuration: 0];
  id ent;
  while ((ent = [en nextObject])){
    if (ent){
      return [ent doubleValue];
    }
  }
  return 0;
}


- (void) redefineLayoutOf: (TrivaGraphNode*) obj
{

/*
	//TODO REVIEW THIS
	if (tree == nil){
		//TODO: review this
		return;
		// NOTE: only falls here if edge is of link type.
		//	the size attribute is necessary to drawing. 
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
		[obj setBoundingBox: rect];
		[obj setDrawable: YES];
		return;
	}
*/

	//getting configuration for this type of node
	NSDictionary *objconf = [configuration objectForKey: [obj type]];
	if (!objconf){
		NSLog (@"%s:%d: no configuration for type %@",
			__FUNCTION__, __LINE__, [obj type]);
		return;
	}

	//getting scale configuration for node
	TrivaScale scale;
	NSString *scaleconf = [objconf objectForKey: @"scale"];
	if (!scaleconf){
		static int flag = 1;
		if (flag){
			NSLog (@"%s:%d: no 'scale' configuration for type %@."
				" Assuming its value as 'global'",
				__FUNCTION__, __LINE__, [obj type]);
			flag = 0;
		}
		scale = Global;
	}else{
		if ([scaleconf isEqualToString: @"global"]) {
			scale = Global;
		}else if ([scaleconf isEqualToString: @"local"]){
			scale = Local;
		}else{
			NSLog (@"%s:%d: unknow 'scale' configuration value "
				"(%@) for type %@",
				__FUNCTION__, __LINE__, scaleconf, [obj type]);
			return;
		}
	}

	//getting values integrated within the time-slice
	TimeSliceTree *t;
	t = (TimeSliceTree*)[[self timeSliceTree] searchChildByName: [obj name]];
	NSMutableDictionary *values = [t timeSliceValues];

  //set timeSliceTree of the object
  [obj setTimeSliceTree: t];

  //setting the bounding box (origin and size)
	NSRect bb;
  if (graphviz){
		if (userPositions == NO) {
			Agnode_t *n = agfindnode (graph,
				(char *)[[obj name] cString]);
			if (n) {
				bb.origin.x = ND_coord_i(n).x;
				bb.origin.y = ND_coord_i(n).y;
			}else{
				bb.origin.x = 0;
				bb.origin.y = 0;
			}
		}else{
			id pos = [configuration objectForKey: [obj name]];
			if (pos){
				bb.origin.x = [[pos objectForKey: @"x"] doubleValue];
				bb.origin.y = [[pos objectForKey: @"y"] doubleValue];
			}else{
				bb.origin.x = 0;
				bb.origin.y = 0;
			}
		}
  }else{
    //ok, user registered in the tracefile the values of x and y
    //we should not take their values integrated in time, because
    //they can be negative values.... 
    NSString *xconf = [objconf objectForKey: @"x"];
    NSString *yconf = [objconf objectForKey: @"y"];

    bb.origin.x=[self getVariableOfTypeName: xconf ofContainerName: [obj name]];
    bb.origin.y=[self getVariableOfTypeName: yconf ofContainerName: [obj name]];

    PajeEntityType *xtype = [self entityTypeWithName: xconf];
    PajeEntityType *ytype = [self entityTypeWithName: yconf];

    double xmax = FLT_MAX, xmin = -FLT_MAX, ymax = FLT_MAX, ymin = -FLT_MAX;
    xmin = [self minValueForEntityType: xtype];
    xmax = [self maxValueForEntityType: xtype];
    ymin = [self minValueForEntityType: ytype];
    ymax = [self maxValueForEntityType: ytype];

		graphSize.origin.x = xmin - (xmax-xmin)*.1;
		graphSize.origin.y = ymin - (ymax-ymin)*.1;
		graphSize.size.width = xmax-xmin + 2*((xmax-xmin)*.1);
		graphSize.size.height = ymax-ymin + 2*((ymax-ymin)*.1);
  }

	//getting size configuration for node
	NSString *sizeconf = [objconf objectForKey: @"size"];
	if (!sizeconf) {
		NSLog (@"%s:%d: no 'size' configuration for type %@",
			__FUNCTION__, __LINE__, [obj type]);
		return;
	}

	//getting max and min for size of node (integrate them in time slice)
	double min, max;
	[self defineMax: &max
                 andMin: &min
              withScale: scale
           fromVariable: sizeconf
               ofObject: [obj name]
               withType: [obj type]];

	//size is mandatory
	double screenSize;
	double size = [self evaluateWithValues: values withExpr: sizeconf];
	if (size < 0){ //negative value if evaluation is unsucessfull
		screenSize = [sizeconf doubleValue];
	}else{
  	screenSize = [self calculateScreenSizeBasedOnValue: size
	  		andMax: max andMin: min];
	}
	bb.size.width = screenSize;
	bb.size.height = screenSize;
	//converting from graphviz center point to top-left origin
	if (userPositions == NO){
		bb.origin.x = bb.origin.x - bb.size.width/2;
		bb.origin.y = bb.origin.y - bb.size.height/2;
	}
	[obj setBoundingBox: bb];
	[obj setDrawable: YES];

	//remove existing compositions
	[obj removeCompositions];

	//iterating through compositions
	NSMutableArray *ar = [NSMutableArray arrayWithArray: [objconf allKeys]];
	NSEnumerator *en = [ar objectEnumerator];
	id compositionName;
	while ((compositionName = [en nextObject])){
		NSDictionary *compconf = [objconf objectForKey: compositionName];
		if (![compconf isKindOfClass: [NSDictionary class]])
			continue; //ignore if not dict
		if (![compconf count])
			continue; //ignore if dictionary is empty

		TrivaComposition *composition;
		composition = [TrivaComposition
                                       compositionWithConfiguration: compconf
                                                          forObject: obj
                                                         withValues: values
                                                        andProvider: self];
		if (composition){
			[obj addComposition: composition];
			[composition release];
		}
	}
}


- (void) redefineNodesEdgesLayout
{
	if (!graph && userPositions == NO){
		NSLog (@"%s:%d: platform graph not created",
			__FUNCTION__, __LINE__);
		return;
	}
	
	NSEnumerator *en = [self enumeratorOfNodes];
	TrivaGraphNode *node;
	while ((node = [en nextObject])){
		[self redefineLayoutOf: node];
	}
	en = [self enumeratorOfEdges];
	TrivaGraphEdge *edge;
	while ((edge = [en nextObject])){
		[self redefineLayoutOf: edge];
	}
}

- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation
{
	if (![[c colorSpaceName] isEqualToString:
			@"NSCalibratedRGBColorSpace"]){
		NSLog (@"%s:%d Color provided is not part of the "
				"RGB color space.", __FUNCTION__, __LINE__);
		return nil;
	}
	float h, s, b, a;
	[c getHue: &h saturation: &s brightness: &b alpha: &a];
	NSColor *ret = [NSColor colorWithCalibratedHue: h
		saturation: saturation
		brightness: b
		alpha: a];
	return ret;
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}

- (void) graphComponentScalingChanged
{
  [self redefineNodesEdgesLayout];
  [super timeSelectionChanged];
}
@end
