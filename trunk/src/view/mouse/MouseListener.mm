#include "view/mouse/MouseListener.h"

MouseListener::MouseListener (ProtoView *view) 
{
	viewController = view;
	[viewController retain];


        // Setup default variables
        mCurrentObject = NULL;
        mLMouseDown = false;
        mRMouseDown = false;

	Ogre::SceneManager *mSceneMgr;
	Ogre::Root *mRoot;
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	mRaySceneQuery = mSceneMgr->createRayQuery(Ogre::Ray());

}

MouseListener::~MouseListener ()
{
	delete mRaySceneQuery;
}


bool MouseListener::mouseMoved(const OIS::MouseEvent &m)
{
	return true;
}

bool MouseListener::mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
       if (b == OIS::MB_Left)
       {
           mLMouseDown = true;
       }
       else if (b == OIS::MB_Right)
       {
           mRMouseDown = true;
       }
       return true;
}

bool MouseListener::mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
	if (b == OIS::MB_Left)
	{
		mLMouseDown = false;
	}
	else if (b == OIS::MB_Right)
	{
		mRMouseDown = false;
	}
	return true;
}

