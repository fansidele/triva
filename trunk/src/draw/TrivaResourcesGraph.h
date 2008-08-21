#ifndef __TRIVA_RESOURCE_GRAPH_H
#define __TRIVA_RESOURCE_GRAPH_H
#include <Foundation/Foundation.h>
#include <gvc.h>

@interface TrivaResourcesGraph : NSObject
{
	NSString *algorithm;
	NSString *file;

	int nContainers, next;
	graph_t *g;
	GVC_t *gvc;
	float maxW, maxH;

	NSString *size, *sepRate;
}
- (id) initWithFile: (NSString *) f;
- (void) setAlgorithm: (NSString *) algo;
- (void) setSize: (NSString *) s;
- (void) setSeparationRate: (NSString *) s;
- (NSArray *) allNodes;
- (NSArray *) allEdges;
- (int) positionXForNode: (NSString *) node;
- (int) positionYForNode: (NSString *) node;
- (double) widthForNode: (NSString *) node;
- (double) heightForNode: (NSString *) node;

- (void) resetNumberOfContainers;
- (NSString *) searchWithPartialName: (NSString *) partialName;
- (void) incrementNumberOfContainersOf: (NSString *) node;

@end
#endif
