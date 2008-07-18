#include "TrivaController.h"

void TrivaController::configureZoom ()
{
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	NSString *v = [d stringForKey:@"pointsPerSecond"];
	double nv;
	if (v != nil){
		nv = [v doubleValue];
	}else{
		nv = 1.0;
	}

	[view setPointsPerSecond: nv];

	xScale = zScale = yScale = 1.0;

	Ogre::Root *mRoot;
	Ogre::SceneManager *mSceneMgr;
	mRoot = Ogre::Root::getSingletonPtr ();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	mSceneMgr->getRootSceneNode()->setScale (xScale,yScale,zScale);
}

void TrivaController::zoomIn ( wxCommandEvent& event )
{
	[view setPointsPerSecond: ([view pointsPerSecond] * 2)];

	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d setObject: [NSString stringWithFormat: @"%f",
				[view pointsPerSecond]]
		forKey: @"pointsPerSecond"];
	[d synchronize];
}

void TrivaController::zoomOut ( wxCommandEvent& event )
{
	[view setPointsPerSecond: ([view pointsPerSecond] / 2)];

	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d setObject: [NSString stringWithFormat: @"%f",
				[view pointsPerSecond]]
		forKey: @"pointsPerSecond"];
	[d synchronize];
}

