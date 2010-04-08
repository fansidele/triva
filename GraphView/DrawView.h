#ifndef __GraphView_h
#define __GraphView_h

#include <AppKit/AppKit.h>

@class GraphView;

@interface DrawView : NSView
{
	GraphView *filter;
}
- (void) setFilter: (GraphView *)f;
- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation;
@end


#include "GraphView.h"

#endif
