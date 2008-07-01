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
	int i;
	maxW = maxH = 0;
	for (i = 0; i < nContainers; i++){
		char str[100];
		snprintf (str, 100, "n%d", i);
		Agnode_t *node = agfindnode (g, str);
		if (ND_coord_i(node).x > maxW){
			maxW = ND_coord_i(node).x;
		}
		if (ND_coord_i(node).y > maxH){
			maxH = ND_coord_i(node).y;
		}
	}
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

- (NSPoint) nextLocation
{
	NSPoint ret = {0,0};
	int next = 0;

	if (nContainers == 0){
		return ret;
	}

	char str[100];
	snprintf (str, 100, "n%d", next);
	Agnode_t *node = agfindnode (g, str);
	if (node != NULL){
		ret.x = (ND_coord_i(node).x * width) / maxW;
		ret.y = (ND_coord_i(node).y * height) / maxH;
	}
	next = (next + 1)%nContainers;
	return ret;
}
@end
