#include "TrivaResourcesGraph.h"
#include <math.h>
#include "src/draw/position/PositionGraphviz.h"

@implementation TrivaResourcesGraph
- (id) initWithFile: (NSString *) f
{
	if (f == nil){
		return nil;
	}

	FILE *fo = fopen ([f cString], "r");
	if (fo == NULL){
		return nil;
	}

	self = [super init];

	file = f;
	[file retain];

	gvc = gvContext();
	g = agread (fo);

	fclose (fo);

	graphs = [[NSMutableDictionary alloc] init];
	nextLocations = [[NSMutableDictionary alloc] init];

	agsafeset (g, "overlap", "false", "false");

	Agnode_t *n = agfstnode (g);
	while (n != NULL){
		agset (n, "trivaValue", "1");
		agsafeset (n, "shape", "rectangle", "ellipse");

		NSString *nodename;
		nodename = [NSString stringWithFormat: @"%s", n->name];
		PositionGraphviz *pos = [[PositionGraphviz alloc] init];
		[graphs setObject: pos forKey: nodename];
		[pos release];

		n = agnxtnode (g, n);
	}
	return self;
}

- (void) dealloc
{
	[file release];
	[algorithm release];

	[graphs release];
	[nextLocations release];
	[super dealloc];
}

- (void) setAlgorithm: (NSString *) algo
{
	if (algorithm != nil){
		[algorithm release];
	}
	algorithm = algo;
	[algorithm retain];
	char str[100];
	snprintf (str, 100, "%s", [algorithm cString]);
	gvLayout (gvc, g, str);	
}

- (void) setSize: (NSString *) s
{
	[size release];
	size = s;
	[size retain];
	//do nothing for now
}

- (void) setSeparationRate: (NSString *) s
{
	[sepRate release];
	sepRate = s;
	[sepRate retain];

	char str[100];
	snprintf (str, 100, "%s", [sepRate cString]);

	agsafeset (g, "sep", str, "");

	snprintf (str, 100, "%s", [algorithm cString]);
	gvLayout (gvc, g, str);	
}

- (NSArray *) allNodes
{
	NSMutableArray *ar = [[NSMutableArray alloc] init];
	Agnode_t *n = agfstnode (g);
	while (n != NULL){
		[ar addObject: [NSString stringWithFormat: @"%s", n->name]];
		n = agnxtnode (g, n);
	}
	[ar autorelease];
	return ar;
}

- (NSArray *) allEdges
{
	NSMutableArray *ar = [[NSMutableArray alloc] init];
	Agnode_t *n = agfstnode (g);
	while (n){
		Agedge_t *e = agfstedge (g, n);
		while (e){
			NSArray *edge = [NSArray arrayWithObjects:
  			  [NSString stringWithFormat: @"%s", e->head->name],
			  [NSString stringWithFormat: @"%s", e->tail->name],
			  nil];
			[ar addObject: edge];
			e = agnxtedge (g, e, n);
		}
		n = agnxtnode (g, n);
	}
	[ar autorelease];
	return ar;
}

- (void) resetNumberOfContainers
{
	[nextLocations release];
	nextLocations = [[NSMutableDictionary alloc] init];

	[graphs release];
	graphs = [[NSMutableDictionary alloc] init];

	Agnode_t *n = agfstnode (g);
	while (n != NULL){
		agset (n, "numberOfContainers", "0");

		PositionGraphviz *pos = [[PositionGraphviz alloc] init];
		[graphs setObject: pos forKey: [NSString stringWithFormat: @"%s", n->name]];
		[pos release];

		n = agnxtnode (g, n);
	}
}

- (NSString *) searchWithPartialName: (NSString *) partialName
{
        NSString *aux2 = [[partialName componentsSeparatedByString: @"_"]
                                lastObject];
	NSString *aux = [[aux2 componentsSeparatedByString: @"-"] objectAtIndex:
0];

	NSString *save = nil;

	Agnode_t *n = agfstnode (g);
	while (n != NULL){
		NSString *name = [NSString stringWithFormat: @"%s", n->name];

		NSRange aaa = NSIntersectionRange ([name rangeOfString: aux2],
                        [aux2 rangeOfString: name]);
	        if (aaa.location != NSNotFound){
			save = name;
	        }

		if ([name isEqualToString: partialName]){
			return name;
		}
		n = agnxtnode (g, n);
	}
	if (save != nil){
		return save;
	}
	return nil;
}

- (void) incrementNumberOfContainersOf: (NSString *) nodeName
{
        char *name = (char *)[nodeName cString];
        Agnode_t *node = agfindnode (g, name);
	if (node != NULL){
		char *vstr = agget (node, "numberOfContainers");
		int x;
		if (vstr == NULL){
			x = 0;
		}else{
			x = atoi (vstr);
		}
		char str[100];
		snprintf (str, 100, "%d", x+1);
		agsafeset (node, "numberOfContainers", str, str);

		//setting width and height of the node
		double x2 = sqrt ((double)x+1);
		snprintf (str, 100, "%.f", x2);
		agsafeset (node, "width", str, str);
		agsafeset (node, "height", str, str);

		//for application containers
		PositionGraphviz *pos = [graphs objectForKey: nodeName];
		[pos addNode: [NSString stringWithFormat: @"n%d", x]];
		[nextLocations setObject: @"0" forKey: nodeName];
	}else{
		//exception?
	}
}

- (int) positionXForNode: (NSString *) nodeName
{
        char *name = (char *)[nodeName cString];
        Agnode_t *node = agfindnode (g, name);
        if (node != NULL){
                return ND_coord_i(node).x;
        }else{
                return 0;
        }
}

- (int) positionYForNode: (NSString *) nodeName
{
        char *name = (char *)[nodeName cString];
        Agnode_t *node = agfindnode (g, name);
        if (node != NULL){
                return ND_coord_i(node).y;
        }else{
                return 0;
        }
}

- (double) widthForNode: (NSString *) nodeName
{
	char *name = (char *)[nodeName cString];
	Agnode_t *node = agfindnode (g, name);
	if (node != NULL){
		return ND_width (node);
	}else{
		return 0;
	}
}

- (double) heightForNode: (NSString *) nodeName
{
	char *name = (char *)[nodeName cString];
	Agnode_t *node = agfindnode (g, name);
	if (node != NULL){
		return ND_height (node);
	}else{
		return 0;
	}
}

- (void) refreshLayout
{
	char str[100];
	snprintf (str, 100, "%s", [algorithm cString]);
	gvLayout (gvc, g, str);	

	//refreshing layout for application containers position
	int i;
	NSArray *allkeys = [graphs allKeys];
	for (i = 0; i < [allkeys count]; i++){
		[[graphs objectForKey: [allkeys objectAtIndex: i]] refresh];
	}
}

- (NSPoint) nextLocationForNodeName: (NSString *) node
{
	NSPoint ret = {0,0};

	if ([nextLocations count] == 0){
		return ret;
	}

	//getting next location for container in node 
	NSString *p = [nextLocations objectForKey: node];
	int x = atoi ([p cString]);
	PositionGraphviz *pos = [graphs objectForKey: node];
	ret.x = [pos positionXForNode: [NSString stringWithFormat: @"n%d", x]];
	ret.y = [pos positionYForNode: [NSString stringWithFormat: @"n%d", x]];

	//compensating the width/height of resource square
	char *name = (char *)[node cString];
	Agnode_t *n = agfindnode (g, name);
	char *vstr = agget (n, "width");
	int width = atoi (vstr);
	vstr = agget (n, "height");
	int height = atoi (vstr);
	ret.x -= (width/2*72);
	ret.y -= (height/2*72);

	//registering next container to be read
	x = x + 1;
	[nextLocations setObject: [NSString stringWithFormat: @"%d", x] 
			forKey: node];
	return ret;
}
@end
