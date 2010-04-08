#ifndef __SIMGRID_H
#define __SIMGRID_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <gvc.h>
#include "SimGridWindow.h"

@interface SimGrid  : PajeFilter
{
	GVC_t *gvc;
	graph_t *platformGraph;
	BOOL platformCreated;
}
- (void) dumpTraceInTextualFormat;
- (BOOL) checkForSimGridHierarchy: (id) type level: (int) level;
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
@end

#endif
