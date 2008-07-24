#include "TrivaResourcesGraph.h"

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

- (NSArray *) allNodes
{
	NSMutableArray *ar = [[NSMutableArray alloc] init];
	Agnode_t *n = agfstnode (g);
	while (n != NULL){
		[ar addObject: [NSString stringWithFormat: @"%s", n->name]];
		n = agnxtnode (g, n);
	}
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
		agset (node, "numberOfContainers", str);
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
@end
