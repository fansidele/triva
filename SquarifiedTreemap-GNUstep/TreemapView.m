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
	return self;
}

- (void) drawTreemapNode: (id) node
{
	NSRect space;
	space.origin.x = [[node treemapRect] x];
	space.origin.y = [[node treemapRect] y];
	space.size.width = [[node treemapRect] width];
	space.size.height = [[node treemapRect] height];

	[[node color] set];
	NSRectFill(space);
	[NSBezierPath strokeRect: space];
	[[NSColor lightGrayColor] set];
	[NSBezierPath strokeRect: space];
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
			//wxColour color = this->findColorForNode (child);
			//dc.SetBrush (color);
			//wxBrush brush (color, wxSOLID);
			//wxColour grayColor = wxColour (wxT("#c0c0c0"));
			[self drawTreemapNode: child];
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
@end
