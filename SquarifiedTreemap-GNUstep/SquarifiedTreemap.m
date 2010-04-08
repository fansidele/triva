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
	NSLog (@"HOU");
	self = [super initWithController: c];
	if (self != nil){
		[NSBundle loadNibNamed: @"SquarifiedTreemap" owner: self];


	}
//	TreemapWindow *window = new TreemapWindow ((wxWindow*)NULL);
//	window->Show();
//	draw = window->getTreemapDraw();
//	draw->setController ((id)self);

	NSLog (@"Hi %@", self);

	currentTreemap = nil;
	fastUpdate = YES;
	return self;
}

- (void) timeSelectionChanged
{
	if (timeSliceTree != nil){
		[timeSliceTree release];
	}
	timeSliceTree = [self timeSliceTree];
	[timeSliceTree retain];

//	if (draw->getMaxDepthToDraw() > [timeSliceTree maxDepth]){
//		draw->setMaxDepthToDraw([timeSliceTree maxDepth]);
//	}
//
//	if (fastUpdate){
//		draw->Refresh();
//		draw->Update();
//	}
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
                      andDepth: (int) depth
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

- (void) setFastUpdate: (BOOL) v
{
	fastUpdate = v;
}
@end
