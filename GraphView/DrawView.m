/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "DrawView.h"

@implementation DrawView
- (BOOL) isFlipped
{
	return YES;
}

- (void) setFilter: (GraphView *)f
{
	filter = f;
}

- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation
{
	if (![[c colorSpaceName] isEqualToString:
			@"NSCalibratedRGBColorSpace"]){
		NSLog (@"%s:%d Color provided is not part of the "
				"RGB color space.", __FUNCTION__, __LINE__);
		return nil;
	}
	float h, s, b, a;
	[c getHue: &h saturation: &s brightness: &b alpha: &a];

	NSColor *ret = [NSColor colorWithCalibratedHue: h
		saturation: saturation
		brightness: b
		alpha: a];
	return ret;
}

- (void)drawRect:(NSRect)frame
{
	NSEnumerator *en;
	TrivaGraphNode *node;
	TrivaGraphEdge *edge;

	NSRect tela = [self bounds];
	[[NSColor whiteColor] set];
	NSRectFill(tela);
	[NSBezierPath strokeRect: tela];
	
	NSRect bb = [filter sizeForGraph];

	//convert and refresh (nodes and edges, but nodes first)
	en = [filter enumeratorOfNodes];
	while ((node = [en nextObject])){
		if (![node drawable]) continue;
		[node convertFrom: bb to: tela];
		[node refresh];
	}

	en = [filter enumeratorOfEdges];
	while ((edge = [en nextObject])){
		if (![edge drawable]) continue;
		[edge convertFrom: bb to: tela];
		[edge refresh];
	}

	//draw edges first, then nodes
	en = [filter enumeratorOfEdges];
	while ((edge = [en nextObject])){
		if (![edge drawable]) continue;
		[edge draw];
	}
	en = [filter enumeratorOfNodes];
	while ((node = [en nextObject])){
		if (![node drawable]) continue;
		[node draw];
	}
}
@end
