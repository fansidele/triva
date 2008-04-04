#include "DrawManager.h"

static Ogre::Real x, y, z;

void DrawManager::createMouseCursors ()
{
	Ogre::Entity *ex, *ez;
	ex = mSceneMgr->createEntity ("x-cursor", Ogre::SceneManager::PT_SPHERE);
	ez = mSceneMgr->createEntity ("z-cursor", Ogre::SceneManager::PT_SPHERE);
	ex->setMaterialName ("VisuApp/XAxis");
	ex->setQueryFlags(AMBIENT_MASK);
	ez->setMaterialName ("VisuApp/ZAxis");
	ez->setQueryFlags(AMBIENT_MASK);

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
		Ogre::Vector3 posi = sn->getPosition();
		
		posi.x = x;
		posi.z = z;
		sn->setPosition (posi);
		
		/* register position */
		NSString *name;
		name = [NSString stringWithFormat:@"%s", sn->getName().c_str()];
		NSMutableArray *b = [pos objectForKey: name];
		[b replaceObjectAtIndex: 0 withObject:[NSString stringWithFormat:@"%d", (int)x]];
		[b replaceObjectAtIndex: 1 withObject:[NSString stringWithFormat:@"%d", (int)z]];
		this->updateLinksPositions();
	}
}

void DrawManager::selectObject (wxMouseEvent& evt, unsigned int mask)
{
        Ogre::Ray mouseRay;

        if (mCurrentObject){
                trivaController->unselectObjectIdentifier(mCurrentObject->getName());
		mCurrentObject->getParentSceneNode()->showBoundingBox(false);
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


#if TRIVADEBUG
	/* drawing the ray */
	Ogre::Vector3 origin = mouseRay.getOrigin();
	Ogre::Vector3 dest = mouseRay.getOrigin() + (mouseRay.getDirection()*10000);
	std::cout << "origin,dest: " << origin << "," << dest << std::endl;
	Ogre::ManualObject *m;
	try {
		m = mSceneMgr->getManualObject ("ray");
	}catch (Ogre::Exception ex){
		m = mSceneMgr->createManualObject ("ray");
	}
	m->clear();
	m->begin ("VisuApp/MPI_SEND", Ogre::RenderOperation::OT_LINE_STRIP);
	m->position (origin);
	m->position (dest);
	m->end();
	m->setQueryFlags(AMBIENT_MASK);
	Ogre::SceneNode *msn;
	try {
		msn = mSceneMgr->getRootSceneNode()->createChildSceneNode ("raysn");
		msn->setInheritScale (false);
	}catch (Ogre::Exception ex){
		msn = mSceneMgr->getSceneNode("raysn");
	}
		
	try {
		msn->getAttachedObject("ray");
	}catch (Ogre::Exception ex){
		msn->attachObject (m);
	}
#endif

        mRaySceneQuery->setRay(mouseRay);
        mRaySceneQuery->setSortByDistance(true,10);
        mRaySceneQuery->setQueryTypeMask(Ogre::SceneManager::ENTITY_TYPE_MASK);
        mRaySceneQuery->setQueryMask (mask);

        Ogre::RaySceneQueryResult &result = mRaySceneQuery->execute();
        Ogre::RaySceneQueryResult::iterator itr;

        Ogre::Vector3 hitAt;
        for ( itr = result.begin(); itr != result.end(); itr++ ) {
                if ( itr->movable ) {
			mCurrentObject = itr->movable;
			hitAt = mouseRay.getPoint( itr->distance );
			break;
                }
        }
        if (mCurrentObject){
//                hitAt.normalise();
                trivaController->selectObjectIdentifier(mCurrentObject, hitAt);
        }else{
                trivaController->unselectObjectIdentifier("");
        }
        mRaySceneQuery->clearResults();
}

void DrawManager::onMouseEvent(wxMouseEvent& evt)
{
	if (evt.LeftDown() && evt.AltDown()){
		this->selectObject (evt, CONTAINER_MASK);
	}else if (evt.LeftDown()){
		this->selectObject (evt, STATE_MASK|LINK_MASK);
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

