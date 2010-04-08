/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GraphView.h"

@implementation GraphView
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
		[NSBundle loadNibNamed: @"Graph" owner: self];
	}
	[view setFilter: self];
	return self;
}

- (void) timeSelectionChanged
{
	[view setNeedsDisplay: YES];
}
@end
