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

	//debug
	myManualObjectNode = NULL;
	myManualObject = NULL;

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

	std::cout << "x,y: " << m.state.X.abs << "," << m.state.Y.abs << " width,height: " << m.state.width << "," << m.state.height << std::endl;
	std::cout << "x/width = " << m.state.X.abs/float(m.state.width) << std::endl;
	std::cout << "y/height = " << m.state.Y.abs/float(m.state.height) << std::endl;

	mouseRay = mCamera->getCameraToViewportRay(m.state.X.abs/float(m.state.width), m.state.Y.abs/float(m.state.height));

/*
	//DEBUG
	if (myManualObjectNode == NULL){
		myManualObjectNode = mSceneMgr->getRootSceneNode()->createChildSceneNode();
	}

	if (myManualObject){
		myManualObjectNode->detachObject("manual1");
 		mSceneMgr->destroyManualObject ("manual1");
	}
	myManualObject =  mSceneMgr->createManualObject("manual1");
	myManualObject->begin("VisuApp/MPI_SEND", Ogre::RenderOperation::OT_LINE_LIST);

	std::cout << mouseRay.getOrigin() << std::endl;
	std::cout << mouseRay.getOrigin()+ mouseRay.getDirection()*100 << std::endl;

	myManualObject->position(mouseRay.getOrigin());
	myManualObject->position(mouseRay.getOrigin() + mouseRay.getDirection()*1000);
	myManualObject->end();
	myManualObjectNode->attachObject(myManualObject);
*/

	mRaySceneQuery->setRay(mouseRay);
	mRaySceneQuery->setSortByDistance(true,1);
	mRaySceneQuery->setQueryTypeMask (Ogre::SceneManager::ENTITY_TYPE_MASK);
	mRaySceneQuery->setQueryMask (STATE_MASK|CONTAINER_MASK|LINK_MASK);

	Ogre::RaySceneQueryResult &result = mRaySceneQuery->execute();
	Ogre::RaySceneQueryResult::iterator itr;
	for ( itr = result.begin(); itr != result.end(); itr++ ) {
		if ( itr->worldFragment ) {
			Ogre::Vector3 location;
			location = itr->worldFragment->singleIntersection;
			std::cout << "WorldFragment: (" << location.x << ", " << location.y << ", " << location.z << ")" << std::endl;
		} else  if ( itr->movable ) {
//			std::cout << "MovableObject: " << itr->movable->getName() << " type: " << itr->movable->getMovableType() << std::endl;
			mCurrentObject = itr->movable;
//			std::cout << "a: " << mCurrentObject->getName().c_str() << std::endl;


			[viewController selectObjectIdentifier: [NSString stringWithFormat: @"%s", mCurrentObject->getName().c_str()]];
			break;
	
		}
	}
	mRaySceneQuery->clearResults();

	std::cout << std::endl;


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

