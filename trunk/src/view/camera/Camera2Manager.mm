#include "view/camera/Camera2Manager.h"

void Camera2Manager::createCamera ()
{
	Ogre::SceneNode *node = mSceneMgr->getRootSceneNode();
	Ogre::SceneNode *childNode = node->createChildSceneNode();

	mCamera = mSceneMgr->createCamera ("Camera2Manager-DefaultCamera");
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

void Camera2Manager::moveCamera ()
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
	mDirection = Ogre::Vector3::ZERO;
}

void Camera2Manager::createViewport ()
{
	Ogre::RenderWindow *mWindow = mRoot->getAutoCreatedWindow();
	mViewport = mWindow->addViewport (mCamera);
	mViewport->setBackgroundColour(Ogre::ColourValue::White);
	mCamera->setAspectRatio (Ogre::Real(mViewport->getActualWidth()) /
				Ogre::Real(mViewport->getActualHeight()));
}

void Camera2Manager::onKeyDownEvent(wxKeyEvent& evt)
{ 
	std::cout << __FILE__ << "::" << __FUNCTION__ << std::endl;
        int key = evt.GetKeyCode();
        switch (key){
		case WXK_NUMPAD9:
			mDirection.y -= mMove;
			break;

		case WXK_NUMPAD7:
			mDirection.y += mMove;
			break;

                case WXK_NUMPAD8:
                case WXK_UP:
			mDirection.z -= mMove;
                        break;

                case WXK_NUMPAD2:
                case WXK_DOWN:
			mDirection.z += mMove;
                        break;

                case WXK_NUMPAD6:
                case WXK_RIGHT:
			mDirection.x += mMove;
                        break;

                case WXK_NUMPAD4:
                case WXK_LEFT:
			mDirection.x -= mMove;
                        break;
                default:
			evt.Skip();
                        break;
        }
	moveCamera();
}

void Camera2Manager::onKeyUpEvent (wxKeyEvent& evt)
{ 
}

void Camera2Manager::onMouseEvent(wxMouseEvent& evt)
{
	std::cout << __FILE__ << "::" << __FUNCTION__ << std::endl;
	std::cout << "X: " << evt.GetX() << " Y: " << evt.GetY() << std::endl;
	if (movingCamera && 0) {
		static int lx = 0, ly = 0;
		int x = (evt.GetX() - lx);
		int y = (evt.GetY() - ly);
		mRotX = Ogre::Degree(-x * mRotate);
		mRotY = Ogre::Degree(-y * mRotate);
		lx = x;
		ly = y;
		moveCamera();
	}
}

bool Camera2Manager::frameEnded (const Ogre::FrameEvent& evt) 
{
	return true; 
} 

bool Camera2Manager::frameStarted (const Ogre::FrameEvent& evt) 
{ 
	moveCamera ();
	std::cout << __FUNCTION__ << std::endl;
	return true; 
} 

Camera2Manager::~Camera2Manager ()
{
	mSceneMgr->destroyAllCameras();
	mRoot->getAutoCreatedWindow()->removeAllViewports();
}

Camera2Manager::Camera2Manager ()
{
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	std::cout << "mSceneMgr = " << mSceneMgr << std::endl;

	createCamera ();
	std::cout << "#1" << std::endl;
	createViewport ();
	std::cout << "#2" << std::endl;
}

void Camera2Manager::changeCamera ()
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

void Camera2Manager::newPositionForCamera (double time)
{
	mCamera->setPosition (Ogre::Vector3 (500, time, 500));
	mCamera->lookAt (Ogre::Vector3 (100,time,100));
}

void Camera2Manager::setMovingCamera (bool m)
{
	movingCamera = m;
}

Camera2Manager::Camera2Manager (Ogre::RenderWindow *win)
{
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	createCamera ();
	createViewport (win);
}

void Camera2Manager::createViewport (Ogre::RenderWindow *win)
{
	mViewport = win->addViewport (mCamera);
	mViewport->setBackgroundColour(Ogre::ColourValue::White);
	mCamera->setAspectRatio (Ogre::Real(mViewport->getActualWidth()) /
				Ogre::Real(mViewport->getActualHeight()));
}
