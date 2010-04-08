#ifndef __SIMGRID_H
#define __SIMGRID_H
#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <graphviz/gvc.h>
#include <limits.h>
#include <float.h>

@interface SimGrid  : TrivaFilter
{
	GVC_t *gvc;
	graph_t *platformGraph;

	NSMutableArray *nodes;		// hosts
	NSMutableArray *edges;		// links

	double maxPower, minPower;
	double maxBandwidth, minBandwidth;
}
- (void) defineMaxMin;
- (void) createSimGridPlatformGraph; /* called when hierarchy changes */
- (void) redefineNodesEdgesLayout; /* called when time selection changes */
@end

#endif
