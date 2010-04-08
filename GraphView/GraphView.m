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
	NSLog (@"view = %@", view);
	return self;
}

- (void) timeSelectionChanged
{
}
@end
