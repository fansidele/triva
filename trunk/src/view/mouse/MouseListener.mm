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
	Ogre::Ray mouseRay;

	if (mCurrentObject){
		[viewController unselectObjectIdentifier: [NSString stringWithFormat: @"%s", mCurrentObject->getName().c_str()]];
		mCurrentObject = NULL;
	}

	Ogre::Camera *mCamera;
	Ogre::SceneManager *mSceneMgr;
	Ogre::Root *mRoot;
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	mCamera = mSceneMgr->getCamera ("CameraManager-DefaultCamera");

	mouseRay = mCamera->getCameraToViewportRay(m.state.X.abs/float(m.state.width), m.state.Y.abs/float(m.state.height));
	mRaySceneQuery->setRay(mouseRay);
	mRaySceneQuery->setSortByDistance(true);

	Ogre::RaySceneQueryResult &result = mRaySceneQuery->execute();
	Ogre::RaySceneQueryResult::iterator itr;
	std::cout << std::endl;
	for ( itr = result.begin(); itr != result.end(); itr++ ) {
/*
		if ( itr->worldFragment ) {
			Ogre::Vector3 location;
			location = itr->worldFragment->singleIntersection;
//			std::cout << "WorldFragment: (" << location.x << ", " << location.y << ", " << location.z << ")" << std::endl;
		} else 
*/
		if ( itr->movable ) {
//			std::cout << "MovableObject: " << itr->movable->getName() << " type: " << itr->movable->getMovableType() << std::endl;
			mCurrentObject = itr->movable;
			[viewController selectObjectIdentifier: [NSString stringWithFormat: @"%s", mCurrentObject->getName().c_str()]];
			break;
	
		}
	}




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

