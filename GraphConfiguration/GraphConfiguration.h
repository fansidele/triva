#ifndef __GraphConfiguration_h
#define __GraphConfiguration_h
#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <graphviz/gvc.h>
#include <limits.h>
#include <float.h>
#include <matheval.h>

@interface GraphConfiguration  : TrivaFilter
{
	GVC_t *gvc;
	graph_t *graph;

	NSMutableArray *nodes;
	NSMutableArray *edges;

	double maxNode, minNode;
	double maxEdge, minEdge;

	NSDictionary *configuration;
}
- (void) setConfiguration: (NSDictionary *) conf;
- (void) createGraph;
- (void) redefineNodesEdgesLayout;
- (void) defineMax: (double*) max
        andMin: (double*) min
        withConfigurationKey: (NSString *) confKey
        fromEnumerator: (NSEnumerator*) en;
- (double) evaluateWithValues: (NSDictionary *) values
                withExpr: (NSString *) expr;
//- (NSArray *) getContainerTypes;
//- (NSArray *) getEntityTypes;
@end

#endif
