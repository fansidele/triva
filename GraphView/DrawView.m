/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
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

#ifdef GNUSTEP
- (BOOL)acceptsFirstResponder
{
    return YES;
}
#endif

- (BOOL)becomeFirstResponder
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    return YES;
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  //search for nodes
  TrivaGraphNode *node;
  NSEnumerator *en = [filter enumeratorOfNodes];
  BOOL found = NO;
  while ((node = [en nextObject])){
    if(NSPointInRect (p, [node screenbb])){
      if (selectedNode){
        [selectedNode setHighlight: NO];
      }
      selectedNode = node;
      [selectedNode setHighlight: YES];
      [self setNeedsDisplay: YES];
      found = YES;
      break;
    }
  }
  if (!found){
    if (selectedNode){
      [selectedNode setHighlight: NO];
      selectedNode = nil;
      [self setNeedsDisplay: YES];
    }
  }
}
@end
