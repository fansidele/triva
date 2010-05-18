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

#include "TreemapView.h"

@implementation TreemapView
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame: frameRect];
	maxDepthToDraw = 0;
	current = nil;
	highlighted = nil;
	updateCurrentTreemap = YES;
	return self;
}

- (void) drawTreemap: (TrivaTreemap*) treemap
{
	if ([treemap treemapValue] == 0){
		return;
	}
	if ([treemap depth] == maxDepthToDraw){
		//draw aggregates
		int nAggChildren, i;
		nAggChildren = [[treemap aggregatedChildren] count];
		for (i = 0; i < nAggChildren; i++){
			TrivaTreemap *child = [[treemap aggregatedChildren]
					objectAtIndex: i];
			[child draw];
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
	if (updateCurrentTreemap){
		TimeSliceTree *tree = [filter timeSliceTree];
        
		if (maxDepthToDraw > [tree maxDepth]){
			maxDepthToDraw = [tree maxDepth];
		}
        
		if (current){
			[current release];
		}
		current = [[TrivaTreemap alloc] initWithTimeSliceTree: tree
				andProvider: filter];
		[current setBoundingBox: b];
		[current refresh];
	}
	[self drawTreemap: current];
	updateCurrentTreemap = YES;
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
			updateCurrentTreemap = NO;
			[self setNeedsDisplay: YES];
		}
	}else{
		if (maxDepthToDraw > 0){
			maxDepthToDraw--;
			updateCurrentTreemap = NO;
			[self setNeedsDisplay: YES];
		}
	}
}

- (void) setHighlight: (id) node highlight: (BOOL) highlight
{
	while (node){
		[node setHighlighted: highlight];
		node = [node parent];
	}	
}

- (void) mouseMoved:(NSEvent *)event
{
	NSPoint p;
	p = [self convertPoint:[event locationInWindow] fromView:nil];

	id node = [current searchWith: p limitToDepth: maxDepthToDraw];
	if (node != highlighted){
		[self setHighlight: highlighted highlight: NO];
		[self setHighlight: node highlight: YES];
		updateCurrentTreemap = NO;
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

- (void)keyDown:(NSEvent *)theEvent
{
  if (([theEvent modifierFlags] | NSAlternateKeyMask) &&
    [theEvent keyCode] == 33){ //ALT + P
    NSPrintOperation *op;
    NSMutableData *data = [NSMutableData data];
    op = [NSPrintOperation EPSOperationWithView: self
                                     insideRect: [self bounds]
                                         toData: data];
    [op runOperation];
    NSString *filename = @"treemap-screenshot.eps";
    [data writeToFile: filename atomically: YES];
    NSLog (@"screenshot written to %@", filename);
  }
}

@end
