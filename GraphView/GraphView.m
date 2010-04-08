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
	[window setDelegate: self];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //window position
        NSPoint point;
        NSString *tx = [NSString stringWithFormat: @"%@OriginX", [window title]];
        NSString *ty = [NSString stringWithFormat: @"%@OriginY", [window title]];
        //check if it exists
        if ([defaults objectForKey: tx] && [defaults objectForKey: ty]){
                point.x = [[defaults objectForKey: tx] doubleValue];
                point.y = [[defaults objectForKey: ty] doubleValue];
                [window setFrameOrigin: point];
        }else{
                [window center];
        }
	return self;
}

- (void) timeSelectionChanged
{
	[view setNeedsDisplay: YES];
}

- (void)windowDidMove:(NSNotification *)win
{
        NSPoint point = [window frame].origin;
        NSString *tx = [NSString stringWithFormat: @"%@OriginX", [window title]];
        NSString *ty = [NSString stringWithFormat: @"%@OriginY", [window title]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSString stringWithFormat: @"%f", point.x] forKey: tx];
        [defaults setObject: [NSString stringWithFormat: @"%f", point.y] forKey: ty];
        [defaults synchronize];
}
@end
