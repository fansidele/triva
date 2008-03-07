#include "TrivaController.h"

void TrivaController::configureZoom ()
{
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	NSString *v = [d stringForKey:@"yScale"];
	if (v != nil){
		yScale = [v doubleValue];
	}else{
		yScale = 1.0;
	}
	xScale = zScale = 1.0;

	Ogre::Root *mRoot;
	Ogre::SceneManager *mSceneMgr;
	mRoot = Ogre::Root::getSingletonPtr ();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	mSceneMgr->getRootSceneNode()->setScale (xScale,yScale,zScale);
}

void TrivaController::zoomIn ( wxCommandEvent& event )
{
	Ogre::Root *mRoot;
	Ogre::SceneManager *mSceneMgr;
	mRoot = Ogre::Root::getSingletonPtr ();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

	yScale += yScale/10;
	mSceneMgr->getRootSceneNode()->setScale (xScale,yScale,zScale);
	
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d setObject: [NSString stringWithFormat: @"%f", yScale] forKey: @"yScale"];
	[d synchronize];
}

void TrivaController::zoomOut ( wxCommandEvent& event )
{
	Ogre::Root *mRoot;
	Ogre::SceneManager *mSceneMgr;
	mRoot = Ogre::Root::getSingletonPtr ();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

	yScale -= yScale/10;
	mSceneMgr->getRootSceneNode()->setScale (xScale,yScale,zScale);

	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d setObject: [NSString stringWithFormat: @"%f", yScale] forKey: @"yScale"];
	[d synchronize];
}

