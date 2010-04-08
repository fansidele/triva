#include "NetworkTopology.h"

@implementation NetworkTopology (ProtoView)
- (void)hierarchyChanged
{
	if ([self rootInstance] == nil){
		return;
	}
	NSLog (@"Recalculating Resources Graph With Application Graph");
	[self recalculateResourcesGraphWithApplicationData];
	NSLog (@"Draw Resources Graph");
	drawManager->resourcesGraphDraw (resourcesGraph);
	NSLog (@"Dreaw Containers in the Resources Graph");
	drawManager->drawContainersIntoResourcesGraphBase ();
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

- (NSDate *) globalStartTime
{
	return [super startTime];
}

- (NSDate *) globalEndTime
{
	return [super endTime];
}
@end
