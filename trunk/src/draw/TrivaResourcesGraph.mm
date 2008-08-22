#include "TrivaResourcesGraph.h"
#include <math.h>

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

	agsafeset (g, "overlap", "false", "false");

	Agnode_t *n = agfstnode (g);
	while (n != NULL){
		agset (n, "trivaValue", "1");
		n = agnxtnode (g, n);
	}

	return self;
}

- (void) dealloc
{
	[file release];
	[algorithm release];
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
	Agnode_t *n = agfstnode (g);
	while (n != NULL){
		agset (n, "numberOfContainers", "0");
		n = agnxtnode (g, n);
	}
}

- (NSString *) searchWithPartialName: (NSString *) partialName
{
        NSString *aux2 = [[partialName componentsSeparatedByString: @"_"]
                                lastObject];
	NSString *aux = [[aux2 componentsSeparatedByString: @"-"] objectAtIndex:
0];

	Agnode_t *n = agfstnode (g);
	while (n != NULL){
		NSString *name = [NSString stringWithFormat: @"%s", n->name];

		NSRange aaa = NSIntersectionRange ([name rangeOfString: aux],
                        [aux rangeOfString: name]);
	        if (aaa.location != NSNotFound){
        	        return name;
	        }
		n = agnxtnode (g, n);
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
		x = x + 1;
		char str[100];
		snprintf (str, 100, "%d", x);
		agsafeset (node, "numberOfContainers", str, str);

		//setting width and height of the node
		double x2 = sqrt ((double)x);
		snprintf (str, 100, "%.f", x2);
		agsafeset (node, "width", str, str);
		agsafeset (node, "height", str, str);
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
}
@end
