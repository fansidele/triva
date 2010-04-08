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
	
	NSRect sr = [[[provider nodes] objectForKey: source] bb];
	NSRect dr = [[[provider nodes] objectForKey: destination] bb];

	NSPoint origin = NSMakePoint (sr.origin.x + sr.size.width/2,
                          sr.origin.y + sr.size.height/2);
	NSPoint dest = NSMakePoint (dr.origin.x + dr.size.width/2,
                          dr.origin.y + dr.size.height/2);
	double w = width/30;
	if (w < 1) w = 1;

	[[[NSColor blueColor] colorWithAlphaComponent: 0.2] set];

        NSPoint oNorm = LMSNormalizePoint (NSSubtractPoints(dest,origin));
        NSPoint oNormPerp = NSMakePoint (-oNorm.y, oNorm.x);

        double distance = LMSDistanceBetweenPoints (dest, origin);
        NSPoint middle = NSSubtractPoints (dest, LMSMultiplyPoint(oNorm,distance/2));
        NSPoint controli = NSAddPoints (middle, LMSMultiplyPoint(oNormPerp,100));
        NSPoint controlv = NSAddPoints (middle, LMSMultiplyPoint(oNormPerp,100-w));

        NSPoint osiNorm = LMSNormalizePoint (NSSubtractPoints(controli, origin));
        NSPoint osiNormPerp = NSMakePoint (-osiNorm.y, osiNorm.x);
        NSPoint dsiNorm = LMSNormalizePoint (NSSubtractPoints(controli, dest));
        NSPoint dsiNormPerp = NSMakePoint (-dsiNorm.y, dsiNorm.x);

        NSPoint osvNorm = LMSNormalizePoint (NSSubtractPoints(controlv, origin));
        NSPoint osvNormPerp = NSMakePoint (-osvNorm.y, osvNorm.x);
        NSPoint dsvNorm = LMSNormalizePoint (NSSubtractPoints(controlv, dest));
        NSPoint dsvNormPerp = NSMakePoint (-dsvNorm.y, dsvNorm.x);

        double d = LMSDistanceBetweenPoints (dest, controli);
        NSPoint base = NSAddPoints (dest, LMSMultiplyPoint(dsiNorm,d*.2));

        NSBezierPath *linha = [NSBezierPath bezierPath];
        //linha
        [linha moveToPoint: NSAddPoints (origin, LMSMultiplyPoint (osiNormPerp, w/2))];
        [linha curveToPoint: NSAddPoints (base, LMSMultiplyPoint (dsiNormPerp, -w/2))
              controlPoint1: controli
              controlPoint2: controli];
        [linha lineToPoint: dest];
        [linha lineToPoint: NSAddPoints (base,  LMSMultiplyPoint (dsvNormPerp, w/2))];
        [linha curveToPoint: NSAddPoints (origin, LMSMultiplyPoint (osvNormPerp,-w/2))
                controlPoint1: controlv
                controlPoint2: controlv];
        [linha lineToPoint: NSAddPoints (origin, LMSMultiplyPoint (osiNormPerp, w/2))];
        [linha fill];


}

- (void) setProvider: (id) prov
{
	provider = prov;
}
@end
