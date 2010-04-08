#ifndef __TrivaGraphEdge_h
#define __TrivaGraphEdge_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "TrivaGraphNode.h"

@interface TrivaGraphEdge : TrivaGraphNode
{
	TrivaGraphNode *source;
	TrivaGraphNode *destination;
}
- (void) setSource: (TrivaGraphNode *) s;
- (void) setDestination: (TrivaGraphNode *) d;
- (TrivaGraphNode *) source;
- (TrivaGraphNode *) destination;
@end

#endif
