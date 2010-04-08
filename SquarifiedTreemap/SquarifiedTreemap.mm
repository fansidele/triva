#include "SquarifiedTreemap.h"
#include "TreemapWindow.h"
#include "TimeSliceAggregation/TimeSliceAggregation.h"

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
	return self;
}

- (void) timeSelectionChanged
{
	TimeSliceAggregation *filter = (TimeSliceAggregation *) inputComponent;
	if (currentTreemap != nil){
		[currentTreemap release];
	}
	currentTreemap = [self defineTreemapWith: [filter timeSliceTree]];
}

- (Treemap *) defineTreemapWith: (TimeSliceTree *) tree
{
	Treemap *node = [[Treemap alloc] init];
	[node autorelease];
	return [node createTreeWithTimeSliceTree: tree];
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
	[currentTreemap calculateTreemapWithWidth: (float)width
				andHeight: (float)height];
	return currentTreemap;
}
@end