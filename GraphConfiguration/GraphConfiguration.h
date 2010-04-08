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

  NSMutableDictionary *configurations; /* nsstring -> nsstring */
  NSDictionary *configuration; //current configuration

  id conf;
  id title;
  id popup;
  id ok;
  id window;
}
- (void) setConfiguration: (NSDictionary *) conf;
- (void) createGraph;
- (void) redefineNodesEdgesLayout;
- (void) defineMax: (double*)max andMin: (double*)min withScale: (TrivaScale) scale
                fromVariable: (NSString*)var
                ofObject: (NSString*) objName withType: (NSString*) objType;
- (double) evaluateWithValues: (NSDictionary *) values
                withExpr: (NSString *) expr;
- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation;
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
