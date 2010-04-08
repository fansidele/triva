#include "Graph.h"
#include "GraphDraw.h"

GraphDraw *draw = NULL;

@implementation Graph
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	GraphWindow *window = new GraphWindow ((wxWindow*)NULL);
	window->Show();
	draw = window->getDraw();
	draw->setController (self);
	return self;
}

- (void) timeSelectionChanged
{
	draw->Refresh();
	draw->Update();
}
@end
