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

	NSPoint s = NSMakePoint (sr.origin.x + sr.size.width/2,
                          sr.origin.y + sr.size.height/2);
	NSPoint d = NSMakePoint (dr.origin.x + dr.size.width/2,
                          dr.origin.y + dr.size.height/2);

	//setting color
	[[[NSColor blueColor] colorWithAlphaComponent: 0.2] set];

	//origin is s, destination is d
	NSPoint vNorm = LMSNormalizePoint (NSSubtractPoints(d, s));
	NSPoint vNormPerp = NSMakePoint (-vNorm.y, vNorm.x);

	//calculating the control point of the bezier curve
	double dist = LMSDistanceBetweenPoints (d, s);
	NSPoint middle = NSSubtractPoints (d, LMSMultiplyPoint(vNorm,dist/2));
	NSPoint control = NSAddPoints (middle, LMSMultiplyPoint(vNormPerp,20));

	//calculating the base of the arrow
	NSPoint cNorm = LMSNormalizePoint (NSSubtractPoints (control, d));
	NSPoint cNormPerp = NSMakePoint (-cNorm.y, cNorm.x);
	NSPoint base = NSSubtractPoints (d , LMSMultiplyPoint(cNorm, -20));

	double w = width/30;
	if (w < 1) w = 1;

	NSBezierPath *linha = [NSBezierPath bezierPath];
	[linha setLineWidth: w];
	[linha moveToPoint: s];
	[linha curveToPoint: base
		controlPoint1: control
		controlPoint2: control];
	[linha stroke];

	NSBezierPath *flecha = [NSBezierPath bezierPath];
	[flecha moveToPoint: d];
	[flecha lineToPoint:
		NSAddPoints (base, LMSMultiplyPoint(cNormPerp,w/2))];
	[flecha lineToPoint:
		NSAddPoints (base, LMSMultiplyPoint(cNormPerp,-w/2))];
	[flecha lineToPoint: d];
	[flecha fill];
}
@end
