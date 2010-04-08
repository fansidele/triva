/* All Rights reserved */
#ifndef __GraphConfiguration_h
#define __GraphConfiguration_h

#include <AppKit/AppKit.h>
#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <graphviz/gvc.h>
#include <limits.h>
#include <float.h>
#include <matheval.h>

@interface GraphConfiguration : TrivaFilter
{
	GVC_t *gvc;
	graph_t *graph;

	NSMutableArray *nodes;
	NSMutableArray *edges;

	double maxNode, minNode;
	double maxEdge, minEdge;

	NSMutableDictionary *configurations; /* nsstring -> nsstring */
	NSDictionary *configuration; //TODO to be removed


  id conf;
  id title;
  id popup;
  id ok;
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
@end

@interface GraphConfiguration (Interface)
- (void) initInterface;
- (void) updateDefaults;
- (void) refreshPopupAndSelect: (NSString*)toselect;
- (void) apply: (id)sender;
- (void) new: (id)sender;
- (void) change: (id)sender;
- (void) updateTitle: (id) sender;
- (void) del: (id) sender;
@end

#endif
