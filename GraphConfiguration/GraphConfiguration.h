#ifndef __GraphConfiguration_h
#define __GraphConfiguration_h
#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <graphviz/gvc.h>
#include <limits.h>
#include <float.h>

@interface GraphConfiguration  : TrivaFilter
{
	GVC_t *gvc;
	graph_t *graph;

	NSMutableArray *nodes;
	NSMutableArray *edges;

	double max, min;
}
- (void) setConfiguration: (NSDictionary *) conf;
//- (NSArray *) getContainerTypes;
//- (NSArray *) getEntityTypes;
@end

#endif
