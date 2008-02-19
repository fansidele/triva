#include "view/ambient/AmbientManager.h"

AmbientManager::~AmbientManager ()
{
}

AmbientManager::AmbientManager () 
{
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

	/* Creating main object (to receive all Y transformations) 
		All others visual objects will be attached to it
	*/
	int size = 10000;
	origin = Origin (mSceneMgr->getRootSceneNode());
	origin.setXAxis (new XAxis (size, 1, &origin));
	origin.setYAxis (new YAxis (size, 1, &origin));
	origin.setZAxis (new ZAxis (size, 1, &origin));
	origin.setGround (new Ground (size, 1, &origin));


	//mSceneMgr->getRootSceneNode()->setScale (1,1,1);
	//mSceneMgr->setAmbientLight(Ogre::ColourValue::White);
}


bool AmbientManager::frameEnded (const Ogre::FrameEvent& evt) 
{
	return true; 
} 

bool AmbientManager::frameStarted (const Ogre::FrameEvent& evt) 
{ 
	return true; 
} 
