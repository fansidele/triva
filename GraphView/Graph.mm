#include "Graph.h"
#include "GraphDraw.h"

#define ROUTER_SIZE 0.1
#define MIN_HOST_SIZE 0.3
#define MIN_LINK_SIZE 0.01

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
	NSLog (@"%s:%d", __FUNCTION__, __LINE__);
	NSLog (@"%@ -> %@", [self selectionStartTime], [self selectionEndTime]);
}

- (void) hierarchyChanged
{
	draw->Refresh();
	draw->Update();
}
@end
