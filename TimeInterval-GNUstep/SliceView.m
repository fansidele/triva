/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "SliceView.h"
#include "TimeInterval.h"

@implementation SliceView
- (void) setFilter: (id) f
{
	filter = f;
}

- (void) drawRect: (NSRect) rect
{
	NSRect b = [self bounds];

	double start = [[[filter startTime] description] doubleValue];
	double end = [[[filter endTime] description] doubleValue];

	double ss = [[[filter selectionStartTime] description] doubleValue];
	double se = [[[filter selectionEndTime] description] doubleValue];

	[[NSColor lightGrayColor] set];
	NSRectFill(b);
	[NSBezierPath strokeRect: b];

	[[NSColor grayColor] set];
	NSRect sel;
	sel.origin.x = ss/(end-start)*b.size.width;
	sel.origin.y = 0;
	sel.size.width = (se-ss)/(end-start)*b.size.width;
	sel.size.height = b.size.height;
	NSRectFill (sel);
	[NSBezierPath strokeRect: sel];
	
	NSRect border;
	border.origin.x = b.origin.x;
	border.origin.y = b.origin.y+1;
	border.size.width = b.size.width-1;
	border.size.height = b.size.height-1;
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect: border];
}
@end
