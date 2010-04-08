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

#include "SquarifiedTreemap.h"

@implementation SquarifiedTreemap
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
		[NSBundle loadNibNamed: @"SquarifiedTreemap" owner: self];
	}
	[view setFilter: self];
	currentTreemap = nil;
	mustBeUpdated = YES;
	return self;
}

- (void) timeSelectionChanged
{
	if (timeSliceTree != nil){
		[timeSliceTree release];
	}
	timeSliceTree = [self timeSliceTree];
	[timeSliceTree doFinalValue];
	[timeSliceTree retain];

	if ([view maxDepthToDraw] > [timeSliceTree maxDepth]){
		[view setMaxDepthToDraw: [timeSliceTree maxDepth]];
	}
	mustBeUpdated = YES;
	[view setNeedsDisplay: YES];
}

- (void) entitySelectionChanged
{
	[self timeSelectionChanged];
}

- (void) containerSelectionChanged
{
	[self timeSelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
	[self timeSelectionChanged];
}

- (Treemap *) treemapWithWidth: (int) width
                     andHeight: (int) height
{
	static double prev_w = 0, prev_h = 0;
	if (width == 0 || height == 0
				|| width > 1000000 || height > 1000000){
		return nil;
	}
	if (prev_w == width &&
            prev_h == height &&
            currentTreemap &&
            !mustBeUpdated){
		return currentTreemap;
	}
	if (currentTreemap != nil){
		[currentTreemap release];
	}
	currentTreemap = [[Treemap alloc] init];
	[currentTreemap createTreeWithTimeSliceTree: timeSliceTree];
	[currentTreemap calculateTreemapWithWidth: (float)width
				andHeight: (float)height];
	prev_w = width;
	prev_h = height;
	mustBeUpdated = NO;
	return currentTreemap;
}
@end
