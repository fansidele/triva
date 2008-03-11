#include "gui/camera/CameraManager.h"

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

void CameraManager::moveCamera ()
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

void CameraManager::onKeyDownEvent(wxKeyEvent& evt)
{ 
//	std::cout << __FILE__ << "::" << __FUNCTION__ << std::endl;
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
		case WXK_ESCAPE:
			if (movingCamera){
				//avisa TrivaController que acabou
				std::cout << "disableInputMouseFocus()"<<
std::endl;
				controller->disableInputMouseFocus ();
			}else{
				evt.Skip();
			}
			break;
                default:
			evt.Skip();
                        break;
        }
	moveCamera();
}

void CameraManager::onKeyUpEvent (wxKeyEvent& evt)
{ 
//	std::cout << __FILE__ << "::" << __FUNCTION__ << std::endl;
}

void CameraManager::onMouseEvent(wxMouseEvent& evt)
{
//	std::cout << __FILE__ << "::" << __FUNCTION__ << std::endl;
	if (movingCamera) {
		static int lx = 0, ly = 0;
		int x = evt.GetX();
		int y = evt.GetY();
		int xdif = (x - lx);
		int ydif = (y - ly);
//		std::cout << "X: " << evt.GetX() << " xdif: " << xdif << std::endl;
//		std::cout << "Y: " << evt.GetY() << " ydif: " << ydif << std::endl;
		mRotX = Ogre::Degree(-xdif * mRotate);
		mRotY = Ogre::Degree(-ydif * mRotate);
		lx = x;
		ly = y;
		moveCamera();
	}
}

CameraManager::~CameraManager ()
{
	mSceneMgr->destroyAllCameras();
	mRenderWindow->removeAllViewports();
}

CameraManager::CameraManager (TrivaController *c, Ogre::RenderWindow *win)
{
	controller = c;
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	createCamera ();
	createViewport (win);
	mRenderWindow = win;
}

void CameraManager::createViewport (Ogre::RenderWindow *win)
{
	mViewport = win->addViewport (mCamera);
	mViewport->setBackgroundColour(Ogre::ColourValue::White);
	mCamera->setAspectRatio (Ogre::Real(mViewport->getActualWidth()) /
				Ogre::Real(mViewport->getActualHeight()));
}

bool CameraManager::frameStarted (const Ogre::FrameEvent& evt) { return true; }
bool CameraManager::frameEnded (const Ogre::FrameEvent& evt) { return true; }

