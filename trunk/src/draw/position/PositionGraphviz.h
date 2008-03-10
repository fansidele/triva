#ifndef __POSITIONGRAPHVIZ_H
#define __POSITIONGRAPHVIZ_H
#include <Foundation/Foundation.h>
#include <gvc.h>
#include "Position.h"

@interface PositionGraphviz : Position
{
	graph_t *g;
	GVC_t *gvc;
	NSMutableDictionary *allNodesIdentifiers;
	NSString *algorithm;



	//NSMutableDictionary *hierarchy;
}
- (void) setSubAlgorithm: (NSString *) newSubAlgorithm;
- (NSString *) subAlgorithm;
@end

#endif
