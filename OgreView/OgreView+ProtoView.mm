#include "OgreView.h"

@implementation OgreView (ProtoView)
/*
- (id)initWithController:(PajeTraceController *)c
{
        self = [super initWithController: c];
        if (self != nil){
		mRoot = Ogre::Root::getSingletonPtr ();
		NSLog (@"initializating drawManager");
		drawManager = new DrawManager (self);
        }
        return self;
}
*/

//- (void) setColorWindow: (TrivaColorWindowEvents *) window
//{
//        mwin = window;
//	return;
//}

/*
- (void) dealloc
{
        NSLog (@"%@ %s", self, __FUNCTION__);
//	[pajeOgreFilter release];
//	delete drawManager;
	[super dealloc];
}
*/


- (void)hierarchyChanged
{
	NSLog (@"%s", __FUNCTION__);
//	return;
	if ([self rootInstance] == nil){
//		return;
	}
	if (baseState == ApplicationGraph){
		NSLog (@"Recalculating Application Graph");
		[self recalculateApplicationGraphWithApplicationData];
		NSLog (@"Drawing application Graph");
//		drawManager->applicationAnimatedGraphDraw
//                                       (applicationGraphPosition, 0.4);
		drawManager->applicationGraphDraw (applicationGraphPosition);
		NSLog (@"Drawing Timestamped objects");
		drawManager->createTimestampedObjects ();
	}else if (baseState == SquarifiedTreemap){
		NSLog (@"Reclaculating squarified treemap with application data");
		[self recalculateSquarifiedTreemapWithApplicationData];
		NSLog (@"drawing the squarified treemap");
		drawManager->squarifiedTreemapDraw (squarifiedTreemap);
		NSLog (@"drawing containers into treemap base");
		drawManager->drawContainersIntoTreemapBase ();
		NSLog (@"drawing timestamped objects");
		drawManager->createTimestampedObjects ();
	}else if (baseState == ResourcesGraph){
		NSLog (@"Recalculating Resources Graph With Application Graph");
		[self recalculateResourcesGraphWithApplicationData];
		NSLog (@"Draw Resources Graph");
		drawManager->resourcesGraphDraw (resourcesGraph);
		NSLog (@"Dreaw Containers in the Resources Graph");
		drawManager->drawContainersIntoResourcesGraphBase ();
		NSLog (@"Drawing Timestamped objects");
		drawManager->createTimestampedObjects ();
	}
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
