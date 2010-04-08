#include "SquarifiedTreemap.h"
#include "TreemapWindow.h"
#include <Triva/TrivaFilter.h>

TreemapDraw *draw = NULL;

@implementation SquarifiedTreemap
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	TreemapWindow *window = new TreemapWindow ((wxWindow*)NULL);
	window->Show();
	draw = window->getTreemapDraw();
	draw->setController ((id)self);

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

	if (draw->getMaxDepthToDraw() > [timeSliceTree maxDepth]){
		draw->setMaxDepthToDraw([timeSliceTree maxDepth]);
	}

	if (fastUpdate){
		draw->Refresh();
		draw->Update();
	}
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
