#include "ProtoView.h"

@implementation ProtoView
- (id) init
{
	self = [super init];
	statesLabelsAppearance = true;
	containersLabelsAppearance = true;

	mRoot = Ogre::Root::getSingletonPtr ();
	NSLog (@"initializating drawManager");
	drawManager = new DrawManager (self);
        mRoot->addFrameListener (drawManager);
	return self;
}

- (void) dealloc
{
        NSLog (@"%s", self, __FUNCTION__);
	delete drawManager;
	[super dealloc];
}

- (void) input: (id) object
{
	/* TODO: arrival of a new object to be drawn. what to do? */
	//NSLog (@"%@", [object class]);
	NSString *str;
	 str = [NSString stringWithFormat: @"%s: TODO", __FUNCTION__];
	[[NSException exceptionWithName: @"ProtoView"
			reason: str userInfo: nil] raise];
}

- (void) timeLimitsChanged
{
	drawManager->movePointer();
	drawManager->createStatesDrawings ();
	drawManager->updateStatesDrawings ();
	drawManager->createLinksDrawings ();

	//cameraManager->newPositionForCamera (atof([[self endTime] cString]));

	/* TODO: new data available at previous components */
	//NSLog (@"%s %p %@", __FUNCTION__, drawManager, [self endTime]);
//	ProtoContainer *r = [self root];
//	NSLog (@"%@", [r identifier]);
}

- (void) hierarchyChanged
{
	/* TODO: */	
	drawManager->updateContainersPositions();
	drawManager->updateContainerDrawings();
	drawManager->updateLinksDrawings ();
}

- (void) connectionsChanged
{
	drawManager->updateContainersPositions();
}

- (XContainer *) root
{
	if (root == nil){
		root = [super root];
	}
	return root;
}

- (void) changePositionAlgorithm
{
	NSLog (@"%s", __FUNCTION__);
	drawManager->changePositionAlgorithm();
	drawManager->updateLinksDrawings ();
}

- (void) switchStatesLabels
{
	statesLabelsAppearance = !statesLabelsAppearance;
	if (statesLabelsAppearance){
		drawManager->showStatesLabels ();
	}else{
		drawManager->hideStatesLabels ();
	}
}

- (void) switchContainersLabels
{
	containersLabelsAppearance = !containersLabelsAppearance;
	if (containersLabelsAppearance){
		drawManager->showContainersLabels ();
	}else{
		drawManager->hideContainersLabels ();
	}
}

- (bool) statesLabelsAppearance
{
	return statesLabelsAppearance;
}

- (bool) containersLabelsAppearance
{
	return containersLabelsAppearance;
}
@end
