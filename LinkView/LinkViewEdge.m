/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <AppKit/AppKit.h>
#include "LinkViewEdge.h"

@implementation LinkViewEdge
- (void) setWidth: (double) w
{
	width = w;
}

- (void) setMaxWidth: (double)m
{
	max = m;
}

- (void) draw
{
	if (!source || !destination){
		return;
	}

	NSRect sr = [[self source] bb];
	NSRect dr = [[self destination] bb];

	NSPoint sp = NSMakePoint (sr.origin.x + sr.size.width/2,
                          sr.origin.y + sr.size.height/2);
	NSPoint dp = NSMakePoint (dr.origin.x + dr.size.width/2,
                          dr.origin.y + dr.size.height/2);

	[[[NSColor blueColor] colorWithAlphaComponent: 0.2] set];
	if (sp.x == dp.x && sp.y == dp.y) {
		return;
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path setLineWidth: width/10];
		[path moveToPoint: sp];
		[path curveToPoint: dp
                        controlPoint1: NSMakePoint (sp.x, sp.y+10)
			controlPoint2: NSMakePoint (sp.x+10, sp.y)];
		[path stroke];
	}else{
		double angle = LMSAngleBetweenPoints (sp, dp);
		double distance = LMSDistanceBetweenPoints (sp, dp);
        
		NSAffineTransform* xform = [NSAffineTransform transform];
		[xform translateXBy: sp.x yBy: sp.y];
		[xform rotateByDegrees: angle];
		[xform concat];
        
		//line
		NSBezierPath *path = [NSBezierPath bezierPath];
		double w = width/10;
		if (w < 1){
			w = 1;
		}
		w = 5;

		NSPoint orig = NSMakePoint (0,0);
		NSPoint dest = NSMakePoint (-distance,0);
		NSPoint control = NSMakePoint ((-distance/2),10);

		[path setLineWidth: w];
		[path moveToPoint: orig];
		[path curveToPoint: dest
                        controlPoint1: control
			controlPoint2: control];
		[path stroke];
	
		NSPoint arrowBase =
			NSMakePoint (control.x + 0.9 * (dest.x - control.x),
					control.y + 0.9 * (dest.y - control.y));

		NSPoint perpArrow = 
			NSMakePoint (-arrowBase.y, arrowBase.x);

		[[NSColor blackColor] set];
		NSRect aRect = NSMakeRect(arrowBase.x, arrowBase.y, 2.0, 2.0);
		NSRectFill (aRect);
		[[[NSColor blueColor] colorWithAlphaComponent: 0.2] set];

/*
		NSPoint thereArrow =
			NSMakePoint (arrowBase.x + 0.1 * (perpArrow.x - arrowBase.x), arrowBase.y + 0.1 * (perpArrow.x - arrowBase.x));

		//arrow
		path = [NSBezierPath bezierPath];
		[path setLineWidth: 1];
		[path moveToPoint: arrowBase];
		[path lineToPoint: NSMakePoint (thereArrow.x, w)];
		[path lineToPoint: dest];
		[path lineToPoint: NSMakePoint (thereArrow.x, -w)];
		[path fill];
		[path stroke];
*/

		[xform invert];
		[xform concat];
	}
}
@end
