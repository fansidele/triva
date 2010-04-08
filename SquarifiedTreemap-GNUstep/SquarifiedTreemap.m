/*
   Project: SquarifiedTreemap

   Copyright (C) 2010 Free Software Foundation

   Author: Lucas Schnorr,,,

   Created: 2010-02-26 13:36:12 +0100 by schnorr

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
	return self;
}

- (void) timeSelectionChanged
{
	if (timeSliceTree != nil){
		[timeSliceTree release];
	}
	timeSliceTree = [self timeSliceTree];
	[timeSliceTree retain];

	if ([view maxDepthToDraw] > [timeSliceTree maxDepth]){
		[view setMaxDepthToDraw: [timeSliceTree maxDepth]];
	}
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
                     andValues: (NSSet *) values
{
	if (width == 0 || height == 0
				|| width > 1000000 || height > 1000000
				|| values == nil){
		return nil;
	}
	[timeSliceTree doFinalValueWith: values];
	if (currentTreemap != nil){
		[currentTreemap release];
	}
	currentTreemap = [[Treemap alloc] init];
	[currentTreemap createTreeWithTimeSliceTree: timeSliceTree
				withValues: values];
	[currentTreemap calculateTreemapWithWidth: (float)width
				andHeight: (float)height];
	return currentTreemap;
}
@end
