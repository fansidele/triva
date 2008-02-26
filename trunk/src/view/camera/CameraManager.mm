#include "view/camera/CameraManager.h"

void CameraManager::createCamera ()
{
	Ogre::SceneNode *node = mSceneMgr->getRootSceneNode();
	Ogre::SceneNode *childNode = node->createChildSceneNode();

	mCamera = mSceneMgr->createCamera ("CameraManager-DefaultCamera");
	mCamera->setNearClipDistance (1);
	mCamera->setPosition (Ogre::Vector3 (500, 500, 500));
	mCamera->lookAt (Ogre::Vector3 (100,0,100));
	mCamera->setQueryFlags(CAMERA_MASK);

	childNode->attachObject (mCamera);

        mRotate = 0.13;
        mMove = 5;
	mDirection = Ogre::Vector3::ZERO;

	movingCamera = false;
}

void CameraManager::moveCamera (const Ogre::FrameEvent& evt)
{
	mCamera->yaw (mRotX);
	mCamera->pitch (mRotY);
	mCamera->moveRelative (mDirection);

	Ogre::Vector3 cameraPos;
	cameraPos = mCamera->getPosition();

	if (cameraPos.y < 0){
		mCamera->moveRelative (-mDirection);
	}

	mRotX = 0;
	mRotY = 0;
}

void CameraManager::createViewport ()
{
	Ogre::RenderWindow *mWindow = mRoot->getAutoCreatedWindow();
	mViewport = mWindow->addViewport (mCamera);
	mViewport->setBackgroundColour(Ogre::ColourValue::White);
	mCamera->setAspectRatio (Ogre::Real(mViewport->getActualWidth()) /
				Ogre::Real(mViewport->getActualHeight()));
}

bool CameraManager::keyPressed (const OIS::KeyEvent &e) 
{ 
	switch (e.key){
		case OIS::KC_E:
			mDirection.y -= mMove;
			break;
		case OIS::KC_Q:
			mDirection.y += mMove;
			break;
		case OIS::KC_W:
			mDirection.z -= mMove;
			break;
		case OIS::KC_S:
			mDirection.z += mMove;
			break;
		case OIS::KC_A:
			mDirection.x -= mMove;
			break;
		case OIS::KC_D:
			mDirection.x += mMove;
			break;
		default:
			break;
	}
	return true; 
}

bool CameraManager::keyReleased (const OIS::KeyEvent &e) 
{ 
	switch (e.key){
		case OIS::KC_E:
			mDirection.y += mMove;
			break;
		case OIS::KC_Q:
			mDirection.y -= mMove;
			break;
		case OIS::KC_W:
			mDirection.z += mMove;
			break;
		case OIS::KC_S:
			mDirection.z -= mMove;
			break;
		case OIS::KC_A:
			mDirection.x += mMove;
			break;
		case OIS::KC_D:
			mDirection.x -= mMove;
			break;
		default:
			break;
	}
	return true; 
}

bool CameraManager::mouseMoved(const OIS::MouseEvent &m)
{
	if (movingCamera){
		mRotX = Ogre::Degree(-m.state.X.rel * mRotate);
		mRotY = Ogre::Degree(-m.state.Y.rel * mRotate);
	}
	return true; 
}

bool CameraManager::mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
	return true; 
}

bool CameraManager::mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
	return true; 
}

bool CameraManager::frameEnded (const Ogre::FrameEvent& evt) 
{
	return true; 
} 

bool CameraManager::frameStarted (const Ogre::FrameEvent& evt) 
{ 
	moveCamera (evt);
	std::cout << __FUNCTION__ << std::endl;
	return true; 
} 

CameraManager::~CameraManager ()
{
	mSceneMgr->destroyAllCameras();
	mRoot->getAutoCreatedWindow()->removeAllViewports();
}

CameraManager::CameraManager ()
{
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	std::cout << "mSceneMgr = " << mSceneMgr << std::endl;

	createCamera ();
	std::cout << "#1" << std::endl;
	createViewport ();
	std::cout << "#2" << std::endl;
}

void CameraManager::changeCamera ()
{
	static int x = 0;
	if (x == 0){
		mCamera->setProjectionType (Ogre::PT_ORTHOGRAPHIC);
		x = 1;
	}else{
		mCamera->setProjectionType (Ogre::PT_PERSPECTIVE);
		x = 0;
	}
}

void CameraManager::newPositionForCamera (double time)
{
	mCamera->setPosition (Ogre::Vector3 (500, time, 500));
	mCamera->lookAt (Ogre::Vector3 (100,time,100));
}

void CameraManager::setMovingCamera (bool m)
{
	movingCamera = m;
}

#ifdef TRIVAWXWIDGETS
CameraManager::CameraManager (Ogre::RenderWindow *win)
{
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	createCamera ();
	createViewport (win);
}

void CameraManager::createViewport (Ogre::RenderWindow *win)
{
	mViewport = win->addViewport (mCamera);
	mViewport->setBackgroundColour(Ogre::ColourValue::White);
	mCamera->setAspectRatio (Ogre::Real(mViewport->getActualWidth()) /
				Ogre::Real(mViewport->getActualHeight()));
}

void CameraManager::moveUp ()
{
	std::cout << __FUNCTION__ << std::endl;
	mDirection.z -= mMove;
	mCamera->moveRelative (mDirection);
}

void CameraManager::moveDown ()
{
	std::cout << __FUNCTION__ << std::endl;
	mDirection.z += mMove;
	mCamera->moveRelative (mDirection);
}

void CameraManager::moveLeft ()
{
	std::cout << __FUNCTION__ << std::endl;
	mDirection.x += mMove;
	mCamera->moveRelative (mDirection);
}

void CameraManager::moveRight ()
{
	std::cout << __FUNCTION__ << std::endl;
	mDirection.x -= mMove;
	mCamera->moveRelative (mDirection);
}
#endif

