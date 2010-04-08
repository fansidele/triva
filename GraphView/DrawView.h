#ifndef __GraphView_h
#define __GraphView_h

#include <AppKit/AppKit.h>

@class GraphView;

@interface DrawView : NSView
{
	GraphView *filter;
}
- (void) setFilter: (GraphView *)f;
- (NSRect) convertRect: (NSRect)input from: (NSRect)bb to:(NSRect) screen;
- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation;
@end


#include "GraphView.h"

#endif
