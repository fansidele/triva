#include "SelectorManager.h"

SelectorManager::SelectorManager (TrivaController *c) 
{
	controller = c;

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

SelectorManager::~SelectorManager ()
{
	delete mRaySceneQuery;
}

void SelectorManager::onMouseEvent(wxMouseEvent& evt)
{
	if (!evt.LeftDown()){
		evt.Skip();
		return;
	}

	Ogre::Ray mouseRay;

	if (mCurrentObject){
		controller->unselectObjectIdentifier(mCurrentObject->getName());
// [NSString stringWithFormat: @"%s", mCurrentObject->getName().c_str()]];
		mCurrentObject = NULL;
	}

	Ogre::Viewport *mViewport;
	Ogre::Camera *mCamera;
	Ogre::SceneManager *mSceneMgr;
	Ogre::Root *mRoot;
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	mCamera = mSceneMgr->getCamera ("CameraManager-DefaultCamera");
	mViewport = mSceneMgr->getCurrentViewport();

//	std::cout << "x,y: " << evt.GetX() << "," << evt.GetY() << std::endl;// width,height: " << m.state.width << "," << m.state.height << std::endl;
//	std::cout << "x/width = " << m.state.X.abs/float(m.state.width) << std::endl;
//	std::cout << "y/height = " << m.state.Y.abs/float(m.state.height) << std::endl;

//	mouseRay = mCamera->getCameraToViewportRay(m.state.X.abs/float(m.state.width), m.state.Y.abs/float(m.state.height));
	mouseRay =
mCamera->getCameraToViewportRay(evt.GetX()/(float)mViewport->getActualWidth(),
evt.GetY()/(float)mViewport->getActualHeight());//m.state.X.abs/float(m.state.width), m.state.Y.abs/float(m.state.height));

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
	mRaySceneQuery->setSortByDistance(true,10);
	mRaySceneQuery->setQueryTypeMask(Ogre::SceneManager::ENTITY_TYPE_MASK);
	mRaySceneQuery->setQueryMask (STATE_MASK|CONTAINER_MASK);

	Ogre::RaySceneQueryResult &result = mRaySceneQuery->execute();
	Ogre::RaySceneQueryResult::iterator itr;


	Ogre::SceneNode *mainSN = NULL;
	Ogre::Vector3 hitAt;


	for ( itr = result.begin(); itr != result.end(); itr++ ) {
		if ( itr->worldFragment ) {
			Ogre::Vector3 location;
			location = itr->worldFragment->singleIntersection;
//			std::cout << "WorldFragment: (" << location.x << ", " << location.y << ", " << location.z << ")" << std::endl;
		} else  if ( itr->movable ) {
			if (mainSN == NULL){
				mCurrentObject = itr->movable;
				mainSN = mCurrentObject->getParentSceneNode()->getParentSceneNode();
				hitAt = mouseRay.getPoint( itr->distance );
			}else{
				if (mainSN == itr->movable->getParentSceneNode()->getParentSceneNode()){
					mCurrentObject = itr->movable;
					hitAt =mouseRay.getPoint(itr->distance);
				}
			}
//			std::cout << "a: " << mCurrentObject->getName().c_str() << std::endl;


//			std::cout << "mouseRay: " << mouseRay.getDirection() << std::endl;
//			controller->selectObjectIdentifier(mCurrentObject);
//			break;
//			std::cout << "cont: " << itr->movable->getParentSceneNode()->getParentSceneNode()->getName() << std::endl;
		}
	}
	if (mCurrentObject){
		hitAt.normalise();
//		std::cout << "SEL # cont: " << mCurrentObject->getParentSceneNode()->getParentSceneNode()->getName() << " nome do estado: " << mCurrentObject->getName() << " pos in time: " << hitAt.y << std::endl;
		controller->selectObjectIdentifier(mCurrentObject, hitAt);
	}else{
		controller->unselectObjectIdentifier("");
	}
	mRaySceneQuery->clearResults();

//	std::cout << std::endl;

/*
       if (b == OIS::MB_Left)
       {
           mLMouseDown = true;
       }
       else if (b == OIS::MB_Right)
       {
           mRMouseDown = true;
       }
       return true;
*/
}
