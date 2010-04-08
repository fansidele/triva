#ifndef __MARCO_H
#define __MARCO_H
#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <graphviz/gvc.h>
#include <limits.h>
#include <float.h>

@interface NUCA  : TrivaFilter
{
	GVC_t *gvc;
	graph_t *graph;

	NSMutableArray *nodes;          // hosts
	NSMutableArray *edges;          // links

	double max, min;
}
@end

#endif
