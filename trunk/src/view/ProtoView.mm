#include "ProtoView.h"

@implementation ProtoView
- (BOOL) setupResources
{
	NSString *resourcescfg = [[NSBundle mainBundle] pathForResource:
@"resources" ofType: @"cfg"];


	//Load resource paths from config file
	Ogre::ConfigFile cf;
	cf.load ([resourcescfg cString]);

	//Go through all settings in the file
	Ogre::ConfigFile::SectionIterator itSection = cf.getSectionIterator();
	Ogre::String sSection, sType, sArch;
	while( itSection.hasMoreElements() ) {
		sSection = itSection.peekNextKey();
		Ogre::ConfigFile::SettingsMultiMap *mapSettings = itSection.getNext();
		Ogre::ConfigFile::SettingsMultiMap::iterator itSetting = mapSettings->begin();
		while( itSetting != mapSettings->end() ) {
			sType = itSetting->first;
			sArch = itSetting->second;
			Ogre::ResourceGroupManager::getSingleton().addResourceLocation(sArch, sType, sSection);
			++itSetting;
		}
	}
	return true;
}

- (BOOL) createRootAndWindow
{


	[self setupResources];
	if (!mRoot->restoreConfig()) {
		if (!mRoot->showConfigDialog()) {
			return false;
		}
	}
	mWindow = mRoot->initialise(true, "TRIVA Visualization System");
	Ogre::ResourceGroupManager::getSingleton().initialiseAllResourceGroups();


	return true;
}

- (BOOL) createSceneManager
{
	mSceneMgr = mRoot->createSceneManager(Ogre::ST_EXTERIOR_CLOSE,
"VisuSceneManager");
	return true;
}



- (id) init
{
	self = [super init];
	yScale = 1;
	yScaleChangeFactor = 0.1;
	planeScale = 1;
	planeScaleChangeFactor = 0.5;
	zoomSwitch = true;
	statesLabelsAppearance = true;
	containersLabelsAppearance = true;

	bundlesConfiguration = [[NSMutableDictionary alloc] init];
	return self;
}

- (BOOL) step1
{
	mRoot = new Ogre::Root("plugins.cfg", "ogre.cfg", "Ogre.log");
	NSLog (@"mRoot = %p", mRoot);


	NSString *resourcescfg = [[NSBundle mainBundle] pathForResource:
@"resources" ofType: @"cfg"];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *currentPath = [fm currentDirectoryPath];
	NSArray *ar = [resourcescfg pathComponents];
	NSMutableArray *ar2 = [NSMutableArray arrayWithArray: ar];
	[ar2 removeLastObject];
	NSString *mediaPath = [NSString pathWithComponents: ar2];
	NSLog (@"mediaPath = %@", mediaPath);

	[fm changeCurrentDirectoryPath: mediaPath];
	[self setupResources];
	[fm changeCurrentDirectoryPath: currentPath];

	mRoot->setRenderSystem (mRoot->getRenderSystemByName ("OpenGL Rendering Subsystem"));

	mRoot->initialise(false);


	return YES;
}

- (BOOL) step4: (Ogre::RenderWindow*) win
{
	mWindow = win;

	cameraManager = new CameraManager (win);
//	mInputMgr->addKeyListener (cameraManager, "CameraManager");
//	mInputMgr->addMouseListener (cameraManager, "CameraManager");
	mRoot->addFrameListener (cameraManager);

	Ogre::ResourceGroupManager::getSingleton().initialiseAllResourceGroups();


	//Create AmbientManager
	NSLog (@"initializating ambientManager");
	ambientManager = new AmbientManager ();
	mRoot->addFrameListener (ambientManager);

	//Create DrawManager
	NSLog (@"initializating drawManager");
	drawManager = new DrawManager (self);
        mRoot->addFrameListener (drawManager);
	return YES;
}




- (void) setController: (ProtoController *) controller
{
}

- (void) dealloc
{
        NSLog (@"%s", self, __FUNCTION__);
	delete mRoot;
	[applicationController release];
	[bundlesConfiguration release];
	[super dealloc];
}

- (BOOL) refresh 
{
	if (mRoot->renderOneFrame() == false){
		return YES;
	}
	Ogre::WindowEventUtilities::messagePump();
	return NO;
}

- (void) end
{
	delete mRoot;
}

- (void) start
{
	NS_DURING
	try {
		while( !bShutdown || false ) {
		}
	}catch (Ogre::Exception &ex){
		std::cerr << "An exception has occured: " <<
			ex.getFullDescription();
	}
	NS_HANDLER
	{
		NSLog (@"##################################################");
		NSLog (@"%@", [localException name]);
		NSLog (@"%@", [localException reason]);
		NSLog (@"%@", [localException userInfo]);
		NSLog (@"##################################################");
		//NSUncaughtExceptionHandler(localException);
	}
	NS_ENDHANDLER

	/* follows a HACK! it should be done in dealloc method, that
		currently is not called */
	delete mRoot;
	return;
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

/*
- (void) startSession
{
	[applicationController startSession: nil];
	root = [super root];
}
*/

- (XContainer *) root
{
	if (root == nil){
		root = [super root];
	}
	return root;
}

- (BOOL) hasMoreData
{
/*
//	NSLog (@"%s", __FUNCTION__);
	if (applicationState == Paused){
		return NO;
	}else{
		return [super hasMoreData];
	}
*/
	return NO;
}

- (void) zoomIn
{
	if (zoomSwitch){
		yScale += yScaleChangeFactor;
	}else{
		planeScale += planeScaleChangeFactor;
	}
	mSceneMgr->getRootSceneNode()->setScale (planeScale,yScale,planeScale);
}

- (void) zoomOut
{
	if (zoomSwitch){
		yScale -= yScaleChangeFactor;
		if (yScale < 0){
			yScale += yScaleChangeFactor;
		}
/*

			yScale -= (yScaleChangeFactor/10);
			if (yScale < 0){
				yScale += (yScaleChangeFactor/10);
				yScale -= (yScaleChangeFactor/100);
				if (yScale < 0){
					yScale += (yScaleChangeFactor/100);
					yScale -= (yScaleChangeFactor/1000);
				}
			}
		}
*/
	}else{
		planeScale -= planeScaleChangeFactor;
		if (planeScale < 0){
			planeScale += planeScaleChangeFactor;
		}
	}
	mSceneMgr->getRootSceneNode()->setScale (planeScale,yScale,planeScale);
}

- (void) adjustZoom
{
//	NSLog (@"%s - %@", __FUNCTION__, [self endTime]);
	double end = [[self endTime] doubleValue];
	while (1){
		if ((double)end >= 100){
			break;
		}
//		if ((int)end == 0){
		end = end*10;
//		}else{
//			break;
//		}
	}
	//NSLog (@"yScale should be %g", end);
	yScale = end;
	yScaleChangeFactor = yScale/100;
	mSceneMgr->getRootSceneNode()->setScale (planeScale,yScale,planeScale);
}

- (void) zoomSwitch
{
	zoomSwitch = !zoomSwitch;
}

- (void) fullscreenSwitch
{
	cameraManager->changeCamera();
	if (mWindow->isFullScreen()){
		NSLog (@"fullscreen ativado, mudando");
		mWindow->setFullscreen (false, 800, 600);
	}else{
		NSLog (@"fullscreen desativado, mudando");
		mWindow->setFullscreen (true, 800, 600);
	}
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

- (void) switchMovingCamera
{
	NSLog (@"%s", __FUNCTION__);
	movingCamera = !movingCamera;
	NSLog (@"\t#1");
	cameraManager->setMovingCamera (movingCamera);
	NSLog (@"\t#2");
//	ceguiManager->setMoveCameraButton (movingCamera);
	NSLog (@"\t#3");
}

- (bool) statesLabelsAppearance
{
	return statesLabelsAppearance;
}

- (bool) containersLabelsAppearance
{
	return containersLabelsAppearance;
}

- (double) yScale
{
	return yScale;
}

- (double) yScaleChangeFactor
{
	return yScaleChangeFactor;
}

- (void) setYScale: (double) y
{
	yScale = y;
        mSceneMgr->getRootSceneNode()->setScale (planeScale,yScale,planeScale);
}

- (CameraManager *) cameraManager
{
	return cameraManager;
}
@end
