#include "TrivaTreemap.h"

@implementation TrivaTreemap (Graphviz)
- (void) initializeGraphvizCategory
{
	if (children == nil){
		gvc = gvContext();
		char str[100] = "Treemap-Graph";
		g = agopen(str, AGRAPHSTRICT);
		nContainers = 0;
	}
}

- (void) calculateMaxWandH
{
	maxW = GD_bb(g).UR.x + 10;
	maxH = GD_bb(g).UR.y + 10;
	return;
}

- (void) incrementNumberOfContainers
{
	char str[100];
	snprintf (str, 100, "n%d", nContainers);
	agnode (g, str);
	nContainers++;
	snprintf (str, 100, "fdp");
	gvLayout (gvc, g, str);
	[self calculateMaxWandH];
}

- (void) decrementNumberOfContainers
{
	if (nContainers == 0){
		return;
	}
	char str[100];
	snprintf (str, 100, "n%d", nContainers-1);
	agdelete (g, str);
	nContainers--;
	snprintf (str, 100, "fdp");
	gvLayout (gvc, g, str);
	[self calculateMaxWandH];
}

- (void) recursiveResetNumberOfContainers
{
	if (children == nil){
		[self resetNumberOfContainers];
	}else{
		unsigned int i;
		for (i = 0; i < [children count]; i++){
			TrivaTreemap *child = [children objectAtIndex: i];
			[child recursiveResetNumberOfContainers];
		}
	}
}

- (void) resetNumberOfContainers
{
	int i;
	for (i = 0; i <= nContainers; i++){
		char str[100];
		snprintf (str, 100, "n%d", i);
		agdelete (g, str);
	}	
	nContainers = 0;
	next = 0;
}

- (NSPoint) nextLocation
{
	NSPoint ret = {0,0};

	if (nContainers == 0){
		return ret;
	}

	char str[100];
	snprintf (str, 100, "n%d", next);
	Agnode_t *node = agfindnode (g, str);
	if (node != NULL){
		float oldx = ND_coord_i(node).x;
		float oldy = ND_coord_i(node).y;
		ret.x = ((oldx * width) / maxW) - width/2;
		ret.y = ((oldy * height) / maxH) - height/2;
	}
	next = (next + 1)%nContainers;
	return ret;
}
@end
