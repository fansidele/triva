#include "ProtoController.h"

#ifndef TRIVAWXWIDGETS

@implementation ProtoController
- (id) initWithArgc: (int) argc andArgv: (char **) argv
{
	self = [super init];

/*
	if (argc > 1){
		reader = [[ProtoReader alloc] initWithArgc: argc andArgv: argv];
		if (reader == nil){
			return nil;
		}
	}
*/

	view = [[ProtoView alloc] init];
	[view setController: self];

	[self startSession];
	
	quit = NO;
	sessionStarted = NO;
	return self;
}

- (void) start
{
	while (!quit){
		quit = [view refresh];

		if (sessionStarted){
			if (![view isPaused]){
				if ([reader hasMoreData]){
					[reader read];
				}
			}
		}
	}
	[view end];
}

- (void) dealloc
{
	NSLog (@"%s", __FUNCTION__);
	NSLog (@"%d", [reader retainCount]);
	[view release];
	[memory release];
	[simulator release];
	[reader release];

	[tracefile release];
	[syncfile release];
	[super dealloc];
}

- (BOOL) startSession
{
	/* destroy previous */
	[self endSession];

	/* create them */
	reader = [[ProtoReader alloc] init];
	simulator = [[OgreProtoSimulator alloc] init];

	/* connect them */
	[reader setOutput: simulator];
	[simulator setInput: reader];
	[simulator setOutput: view];
	[view setInput: simulator];

	NSLog (@"%s", __FUNCTION__);
	sessionStarted = YES;
	return true;
}

- (BOOL) endSession
{
	//[reader release]; for now, he is iniatilized just once
	[simulator release];
	[memory release];

	return true;
}

/*
- (void) applicationWillFinishLaunching: (NSNotification *)not
{
	NSLog (@"############################################");
	NSLog (@"%s", __FUNCTION__);
}

*/

- (void)applicationWillTerminate:(NSNotification *)notif
{
	NSLog (@"############################################");
	NSLog (@"%s", __FUNCTION__);
}

- (void) setSyncfile: (NSString *) f
{
	syncfile = f;
	[syncfile retain];
}

- (void) setTracefile: (NSArray *) a
{
	tracefile = a;
	[tracefile retain];
}

- (NSString *) syncfile
{
	return syncfile;
}

- (NSArray *) tracefile
{
	return tracefile;
}
@end

#else //TRIVAWXWIDGETS

IMPLEMENT_APP(ProtoController);

bool ProtoController::OnInit()
{
	pool = [[NSAutoreleasePool alloc] init];
        Ogre::Root *mRoot;
        Ogre::RenderWindow *mWindow;
        Ogre::SceneManager *mSceneMgr;

        mRoot = new Ogre::Root("plugins.cfg", "ogre.cfg", "Ogre.log");
        Ogre::ConfigFile cf;
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



        cf.load ([resourcescfg cString]);
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
        if (!mRoot->restoreConfig()) {
                if (!mRoot->showConfigDialog()) {
                        return false;
                }
        }

	[fm changeCurrentDirectoryPath: currentPath];


        std::cout << "FIM INIT DO OGRE" << std::endl;
        mWindow = mRoot->initialise(false,"Application");


	TRIVAGUI *gui = new TRIVAGUI (0, wxID_ANY);

        wxOgreRenderWindow *mOgre = gui->mOgre;
        mOgre->createRenderWindow ();

        Ogre::RenderWindow *win = mOgre->getRenderWindow();
        std::cout << "Win = " << win << std::endl;
        mSceneMgr = mRoot->createSceneManager(Ogre::ST_EXTERIOR_CLOSE, "VisuSceneManager");

        Ogre::Camera *mCamera = mSceneMgr->createCamera("PlayerCam");
        mCamera->setPosition(Ogre::Vector3(0,10,500));
        mCamera->lookAt(Ogre::Vector3(0,0,0));


        Ogre::Viewport* vp = win->addViewport(mCamera);
        vp->setBackgroundColour(Ogre::ColourValue::Red);
        mCamera->setAspectRatio(Ogre::Real(vp->getActualWidth()) /
Ogre::Real(vp->getActualHeight()));


        mSceneMgr->setAmbientLight(Ogre::ColourValue(0, 0, 1));
        mSceneMgr->setShadowTechnique(Ogre::SHADOWTYPE_STENCIL_ADDITIVE);

        Ogre::Entity *ent = mSceneMgr->createEntity("aaa", Ogre::SceneManager::PT_CUBE);
	ent->setMaterialName ("VisuApp/MPI_SEND");
        ent->setCastShadows(true);
        mSceneMgr->getRootSceneNode()->createChildSceneNode()->attachObject(ent);



	gui->Show();
	sessionStarted = true;
	return true;
}



#endif //TRIVAWXWIDGETS
