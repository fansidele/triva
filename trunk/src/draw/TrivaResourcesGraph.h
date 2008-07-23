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
}
- (id) initWithFile: (NSString *) f;
- (void) setAlgorithm: (NSString *) algo;
@end
#endif
