#include "CommunicationPattern.h"

@implementation CommunicationPattern (ProtoView)
- (void)hierarchyChanged
{
	if ([self rootInstance] == nil){
		return;
	}
	NSLog (@"Recalculating Application Graph");
	[self recalculateApplicationGraphWithApplicationData];
	NSLog (@"Drawing application Graph");
//	drawManager->applicationAnimatedGraphDraw
//                               (applicationGraphPosition, 0.4);
	drawManager->applicationGraphDraw (applicationGraphPosition);
	NSLog (@"Drawing Timestamped objects");
	drawManager->createTimestampedObjects ();
}

- (void) timeLimitsChanged
{
	[self hierarchyChanged];
}

- (void) timeSelectionChanged
{
	[self hierarchyChanged];
}

- (DrawManager *) drawManager
{
	return drawManager;
}

- (void) setPointsPerSecond: (double) nv
{
	pointsPerSecond = nv;
	NSLog (@"pointsPerSecond is %f", nv);
	drawManager->createTimestampedObjects ();
//	[self hierarchyChanged];
}

- (double) pointsPerSecond
{
	return pointsPerSecond;
}

- (Position *) getApplicationGraphPosition
{
        return applicationGraphPosition;
}
@end
