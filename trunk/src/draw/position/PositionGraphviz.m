#include "PositionGraphviz.h"
#include <sys/time.h>

@implementation PositionGraphviz
- (id) init
{
	self = [super init];
	gvc = gvContext();
	g = agopen("Positioning-Graph", AGRAPHSTRICT);
	allNodesIdentifiers = [[NSMutableDictionary alloc] init];
	algorithm = [NSString stringWithString: @"twopi"];
	[algorithm retain];
//	hierarchy = nil;
	return self;
}

- (void) dealloc
{
	[allNodesIdentifiers release];
	[super dealloc];
}

- (void) refresh
{
	int i;
	gvFreeLayout (gvc, g);
	gvLayout (gvc, g, (char *)[algorithm cString]);
	NSArray *ar = [allNodesIdentifiers allKeys];
	for (i = 0; i < [ar count]; i++){
		NSString *nodeName = [ar objectAtIndex: i];
		int x = [self positionXForNode: nodeName];
		int y = [self positionYForNode: nodeName];
		NSMutableArray *b = [[NSMutableArray alloc] init];
		[b addObject: [NSString stringWithFormat: @"%d", x]];
		[b addObject: [NSString stringWithFormat: @"%d", y]];
		[allNodesIdentifiers setObject: b forKey: nodeName];
		[b release];
	}
//	gvRenderFilename (gvc, g, "png", "out.png");
}

- (void) addNode: (NSString *) nodeName
{
        NSString *str;
           str = [NSString stringWithFormat: @"%@: %s not implemented", self, __FUNCTION__];
            [[NSException exceptionWithName: @"PositionGraphviz"
                   reason: str userInfo: nil] raise];
	return;
/*
	char *name = (char *)[nodeName cString];
	Agnode_t *newnode = agnode (g, name);
	if (newnode != NULL){
		agINSnode (g, newnode);
		[allNodesIdentifiers setObject: [NSArray array] forKey: nodeName];
	}else{
	}
*/
}

- (void) delNode: (NSString *) nodeName
{
             NSString *str;
                str = [NSString stringWithFormat: @"%@: %s not implemented", self, __FUNCTION__];
                 [[NSException exceptionWithName: @"PositionGraphviz"
                        reason: str userInfo: nil] raise];
	return;
}

- (void) addLinkBetweenNode: (NSString *) nodeName 
		andNode: (NSString *) nodeName2
{
	char *name = (char *)[nodeName cString];
	char *name2 = (char *)[nodeName2 cString];
	Agnode_t *one = agfindnode (g, name);
	Agnode_t *two = agfindnode (g, name2);

	Agedge_t *e = agfindedge (g, one, two);
	if (e == NULL){
		agedge (g, one, two);
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

- (void) setPositionX: (int) x forNode: (NSString *) nodeName 
{
	char *name = (char *)[nodeName cString];
	Agnode_t *node = agfindnode (g, name);
	if (node != NULL){
		ND_coord_i(node).x = x;
	}
}

- (void) setPositionY: (int) y forNode: (NSString *) nodeName 
{
	char *name = (char *)[nodeName cString];
	Agnode_t *node = agfindnode (g, name);
	if (node != NULL){
		ND_coord_i(node).y = y;
	}
}

- (NSMutableDictionary *) positionForAllNodes
{
	[self refresh];
	return allNodesIdentifiers;
}

- (void) setSubAlgorithm: (NSString *) newSubAlgorithm;
{
	NSLog (@"%s -> %@", __FUNCTION__, newSubAlgorithm);
	[algorithm release];
	algorithm = newSubAlgorithm;
	[self refresh];
	[algorithm retain];
}

- (NSString *) subAlgorithm
{
	return algorithm;
}

- (void) recreatingGraphWithDictionary: (NSDictionary *) h
			withinSubGraph: (Agraph_t *) graph
{
	if (h == nil){
		return;
	}

	NSArray *a = [h allKeys];
	unsigned int i;
	for (i = 0; i < [a count]; i++){
		NSString *s = [a objectAtIndex: i];
		char *str = (char *)[s cString];
		NSDictionary *d = [h objectForKey: s];
		if ([d count] == 0){ 
			/* is a node */
			Agnode_t *n = agfindnode (graph, str);
			if (n == NULL){
				n = agnode (graph, str);
				[allNodesIdentifiers setObject: [NSArray array] forKey: s];
			}
		}else{
			/* is a subgraph */
			char str2[1000];
			bzero (str2, 1000);
			strncpy (str2, "cluster-", strlen ("cluster-"));
			strncat (str2, str, strlen(str));
			strncat (str2, "\0", 1);

			/* ok, first, was a node? */
			Agnode_t *n = agfindnode (g, str);
			if (n != NULL){ 
				agdelete (g, n); /* if yes, delete it */
				[allNodesIdentifiers removeObjectForKey: s];
			}

			/* subgraph already exists ? */
			Agraph_t *sub = agfindsubg (graph, str2);
			if (sub == NULL){
				sub = agsubg (graph, str2);
			}
			/* recurse */
			[self recreatingGraphWithDictionary: d 
					withinSubGraph: sub];
		}
	}
	

}

- (void) newHierarchyOrganization: (NSDictionary *) h
{
	[self recreatingGraphWithDictionary: h withinSubGraph: g];
}

@end
