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
	NSMutableDictionary *sizes;	// sizes of hosts,links

	double maxPower, minPower;
	double maxBandwidth, minBandwidth;
}
- (void) createPlatformGraph;


/*
- (NSArray *) getHosts;
- (NSArray *) getLinks;
- (NSPoint) getPositionForHost: (id) host;
- (void) setPositionForHost: (id) host toPoint: (NSPoint) p;
- (NSRect) getSizeForHost: (id) host;
- (float) getSizeForLink: (id) link;
- (NSRect) getBoundingBox;


- (NSDictionary *) getPowerUtilizationOfHost: (id) host;
- (NSDictionary *) getBandwidthUtilizationOfLink: (id) link;
- (NSDictionary *) getUtilization: (NSString *) field
		     forContainer: (id) container
		     withMaxValue: (NSString *) maxField;
*/
@end

#endif
