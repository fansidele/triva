#include "DrawManager.h"

static Ogre::Real x, y, z;

void DrawManager::createMouseCursors ()
{
	Ogre::Entity *ex, *ez;
	ex = mSceneMgr->createEntity ("x-cursor", Ogre::SceneManager::PT_SPHERE);
	ez = mSceneMgr->createEntity ("z-cursor", Ogre::SceneManager::PT_SPHERE);
	ex->setMaterialName ("VisuApp/XAxis");
	ez->setMaterialName ("VisuApp/ZAxis");

	Ogre::SceneNode *origin = mSceneMgr->getSceneNode ("Origin");
	Ogre::SceneNode *cx = origin->createChildSceneNode ("x-cursor");
	cx->attachObject (ex);	
	cx->setInheritScale (false);
	Ogre::SceneNode *cz = origin->createChildSceneNode ("z-cursor");
	cz->attachObject (ez);
	cz->setInheritScale (false);

	cx->scale (.1,.1,.1);
	cz->scale (.1,.1,.1);

	x = y = z = 0;
	cx->setPosition (x,y,z);
	cz->setPosition (x,y,z);
}

void DrawManager::moveMouseCursors (wxMouseEvent& evt)
{
        Ogre::Ray mouseRay;
        Ogre::Camera *mCamera;
	Ogre::Viewport *mViewport;
	Ogre::RaySceneQuery *sceneQuery;


        mViewport = mSceneMgr->getCurrentViewport();
	mCamera = mSceneMgr->getCamera ("CameraManager-DefaultCamera");
        mouseRay = mCamera->getCameraToViewportRay(evt.GetX()/(float)mViewport->getActualWidth(), evt.GetY()/(float)mViewport->getActualHeight());

	Ogre::Plane zplane = Ogre::Plane (Ogre::Vector3::UNIT_Z, 0);
	Ogre::Plane yplane = Ogre::Plane (Ogre::Vector3::UNIT_Y, 0);
	std::pair<bool,Ogre::Real> zres = mouseRay.intersects (zplane);
	std::pair<bool,Ogre::Real> yres = mouseRay.intersects (yplane);

	if (zres.first){
		y = mouseRay.getPoint(zres.second).y;
	}else{
		y = 0;
	}

	if (yres.first){
		x = mouseRay.getPoint(yres.second).x;
		z = mouseRay.getPoint(yres.second).z;
	}else{
		x = 0;
		z = 0;
	}

	Ogre::SceneNode *cx = mSceneMgr->getSceneNode ("x-cursor");
	cx->setPosition (x, 0,0);
	Ogre::SceneNode *cz = mSceneMgr->getSceneNode ("z-cursor");
	cz->setPosition (0,0, z);
}

void DrawManager::moveObject (wxMouseEvent& evt)
{
	if (mCurrentObject == NULL){
		return;
	}

	if (mCurrentObject->getQueryFlags () == CONTAINER_MASK ||
		mCurrentObject->getQueryFlags () == STATE_MASK){

		Ogre::SceneNode *sn = mCurrentObject->getParentSceneNode()->getParentSceneNode();
		Ogre::Vector3 pos = sn->getPosition();
		
		std::cout << pos << std::endl;
		pos.x = x;
		pos.z = z;
		sn->setPosition (pos);
	}
}

void DrawManager::selectObject (wxMouseEvent& evt)
{
        Ogre::Ray mouseRay;

        if (mCurrentObject){
                trivaController->unselectObjectIdentifier(mCurrentObject->getName());
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

        mouseRay = mCamera->getCameraToViewportRay(evt.GetX()/(float)mViewport->getActualWidth(), evt.GetY()/(float)mViewport->getActualHeight());

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
                }
        }
        if (mCurrentObject){
                hitAt.normalise();
                trivaController->selectObjectIdentifier(mCurrentObject, hitAt);
        }else{
                trivaController->unselectObjectIdentifier("");
        }
        mRaySceneQuery->clearResults();
}

void DrawManager::onMouseEvent(wxMouseEvent& evt)
{
	if (evt.LeftDown()){
		this->selectObject (evt);
	}
	if (evt.LeftIsDown() && evt.ControlDown()){
		this->moveObject (evt);
	}
	this->moveMouseCursors (evt);
	return;
}

void DrawManager::onKeyDownEvent(wxKeyEvent& evt)
{
	evt.Skip();
}

void DrawManager::setTrivaController (TrivaController *triva)
{
        trivaController = triva;
}

