#include "TrivaGraphEdge.h"
#include <math.h>

double LMSAngleBetweenPoints (NSPoint pt1, NSPoint pt2)
{
	double ptxd = pt1.x - pt2.x;
	double ptyd = pt1.y - pt2.y;
	return 90-(atan2 (ptxd, ptyd)/M_PI*180);
}

double LMSDistanceBetweenPoints(NSPoint pt1, NSPoint pt2)
{
	double ptxd = pt1.x - pt2.x;
	double ptyd = pt1.y - pt2.y;
	return sqrt( ptxd*ptxd + ptyd*ptyd );
}

@implementation TrivaGraphEdge
- (void) setSource: (TrivaGraphNode *) s;
{
	[source release];
	source = s;
	[source retain];
}

- (void) setDestination: (TrivaGraphNode *) d
{
	[destination release];
	destination = d;
	[destination retain];
}

- (TrivaGraphNode *) source
{
	return source;
}

- (TrivaGraphNode *) destination
{
	return destination;
}

- (void) dealloc
{
	[source release];
	[destination release];
	[super dealloc];
}

- (void) setBoundingBox: (NSRect) b
{
	//get size from b.size.width (or b.size.height)
	//ignore the rest of b
	bb.origin.x = 0;
	bb.origin.y = 0;
	bb.size.width = b.size.width;
	bb.size.height = b.size.height;
}

- (void) draw
{
	NSRect srcRect = [source screenbb];
	NSRect dstRect = [destination screenbb];
	NSPoint srcPoint = NSMakePoint (srcRect.origin.x+srcRect.size.width/2,
					srcRect.origin.y+srcRect.size.height/2);
	NSPoint dstPoint = NSMakePoint (dstRect.origin.x+dstRect.size.width/2,
					dstRect.origin.y+dstRect.size.height/2);
	double angle = LMSAngleBetweenPoints (dstPoint, srcPoint);

	NSAffineTransform* xform = [NSAffineTransform transform];
	[xform translateXBy: srcPoint.x yBy: srcPoint.y];
	[xform rotateByDegrees: angle];
	[xform concat];
	[super draw];
	[xform invert];
	[xform concat];
}

- (void) refresh
{
	//screenbb is already updated by call to [convertFrom:bb to:tela]
	//(of superclass). must calculate here the part of screenbb related
	//to the distance between the nodes

	//calculate the distance from src to dst
	NSRect srcRect = [source screenbb];
	NSRect dstRect = [destination screenbb];
	NSPoint srcPoint = NSMakePoint (srcRect.origin.x+srcRect.size.width/2,
					srcRect.origin.y+srcRect.size.height/2);
	NSPoint dstPoint = NSMakePoint (dstRect.origin.x+dstRect.size.width/2,
					dstRect.origin.y+dstRect.size.height/2);
	double distance = LMSDistanceBetweenPoints (srcPoint, dstPoint);
	screenbb.size.width = distance;

	//divide my space among my compositions
	[super refresh];
}
@end
