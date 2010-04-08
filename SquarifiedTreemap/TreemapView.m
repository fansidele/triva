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
/*
   Project: SquarifiedTreemap

   Copyright (C) 2010 Free Software Foundation

   Author: Lucas Schnorr,,,

   Created: 2010-02-26 13:58:50 +0100 by schnorr

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include "TreemapView.h"

@implementation TreemapView
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame: frameRect];
	maxDepthToDraw = 0;
	current = nil;
	highlighted = nil;
	return self;
}

- (void) drawTreemapNode: (id) node
              withOffset: (double) offset
               withColor: (NSColor *)col
         withBorderColor: (NSColor *)bor
{
	double x, y, width, height;
	NSRect space;
	x = space.origin.x = [[node treemapRect] x];
	y = space.origin.y = [[node treemapRect] y];
	width = space.size.width = [[node treemapRect] width];
	height = space.size.height = [[node treemapRect] height];


	[col set];
	NSRectFill(space);
	[NSBezierPath strokeRect: space];
	[bor set];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint: NSMakePoint (x+offset,y+offset)];
	[path lineToPoint: NSMakePoint (x+width-offset, y+offset)];
	[path lineToPoint: NSMakePoint (x+width-offset, y+height-offset)];
	[path lineToPoint: NSMakePoint (x+offset, y+height-offset)];
	[path lineToPoint: NSMakePoint (x+offset, y+offset)];
	[path stroke];
}

- (void) drawTreemap: (id) treemap
{
	if ([treemap val] == 0){
		return;
	}
	if ([treemap depth] == maxDepthToDraw){
		//draw aggregates
		int nAggChildren, i;
		nAggChildren = [[treemap aggregatedChildren] count];
		for (i = 0; i < nAggChildren; i++){
			id child = [[treemap aggregatedChildren]
					objectAtIndex: i];
			if ([child highlighted]){
				[self drawTreemapNode: child
                                           withOffset: 1
                                            withColor: [child color]
                                      withBorderColor: [NSColor blackColor]];
			}else{
				[self drawTreemapNode: child
                                           withOffset: 0
                                            withColor: [child color]
                                      withBorderColor:[NSColor lightGrayColor]];
			}
		}
	}else{
		//recurse
		int i;
		for (i = 0; i < [[treemap children] count]; i++){
			[self drawTreemap: [[treemap children]
						objectAtIndex: i]];
		}
	}
}

- (BOOL) isFlipped
{
	return YES;
}

- (void)drawRect:(NSRect)frame
{
	NSRect b = [self bounds];
	current = [filter treemapWithWidth: b.size.width
                                         andHeight: b.size.height
                                         andValues: [NSSet set]];
	[self drawTreemap: current];
}

- (void) setHighlight: (id) node highlight: (BOOL) highlight
{
	while (node){
		[node setHighlighted: highlight];
		node = [node parent];
	}	
}

- (void) setMaxDepthToDraw: (int) d
{
	maxDepthToDraw = d;
}

- (int) maxDepthToDraw
{
	return maxDepthToDraw;
}

- (void) setFilter: (SquarifiedTreemap *) f
{
	filter = f;
}

- (void)scrollWheel:(NSEvent *)event
{
	if ([event deltaY] > 0){
		if (maxDepthToDraw < [current maxDepth]){
			maxDepthToDraw++;
			[self setNeedsDisplay: YES];
		}
	}else{
		if (maxDepthToDraw > 0){
			maxDepthToDraw--;
			[self setNeedsDisplay: YES];
		}
	}
}

- (void) mouseMoved:(NSEvent *)event
{
	NSPoint p;
	p = [self convertPoint:[event locationInWindow] fromView:nil];

	id node = [current searchWith: p limitToDepth: maxDepthToDraw
		andSelectedValues: [NSSet set]];
	if (node != highlighted){
		[self setHighlight: highlighted highlight: NO];
		[self setHighlight: node highlight: YES];
		[self setNeedsDisplay: YES];
		highlighted = node;
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

@end
