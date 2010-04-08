#include "CameraManager.h"

void CameraManager::createCamera (Ogre::Vector3 position, Ogre::Vector3 direction)
{
	Ogre::SceneNode *node = mSceneMgr->getRootSceneNode();

	mCamera = mSceneMgr->createCamera ("CameraManager-DefaultCamera");
	mCamera->setNearClipDistance (1);
	mCamera->setQueryFlags(CAMERA_MASK);
	mCamera->setDirection (direction);

	camNode = node->createChildSceneNode("CameraNode");
	camNode->attachObject (mCamera);
	camNode->setPosition (position);

        mRotate = 0.13;
        mMove = 35;
	mDirection = Ogre::Vector3::ZERO;

	movingCamera = false;

	//creating a light attached to the camera's scenenode
	Ogre::Light *light;
	light = mSceneMgr->createLight("CameraLight");
	light->setType(Ogre::Light::LT_POINT);
	camNode->attachObject(light);
}

void CameraManager::moveCamera ()
{
	mCamera->yaw (mRotX);
	mCamera->pitch (mRotY);
	camNode->translate (mCamera->getOrientation() * mDirection);

	Ogre::Vector3 cameraPos;
	cameraPos = camNode->getPosition();

	if (cameraPos.y < 0){
		camNode->translate (mCamera->getOrientation() * -mDirection);
	}

	mRotX = 0;
	mRotY = 0;
	mDirection = Ogre::Vector3::ZERO;
}

void CameraManager::moveCameraToY (float y)
{
	static float anty = 0;
	
	Ogre::Vector3 cameraPos;
	cameraPos = camNode->getPosition();
	cameraPos.y += (y - anty);
	camNode->setPosition (cameraPos);
	anty = y;
}

float CameraManager::getYPosition ()
{
	return camNode->getPosition().y;
}

void CameraManager::onKeyDownEvent(wxKeyEvent& evt)
{ 
        int key = evt.GetKeyCode();
//	std::cout << __FILE__ << "::" << __FUNCTION__ << " " << key << std::endl;
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
		case WXK_NUMPAD_ADD:
			controller->zoomIn();
			break;
		case WXK_NUMPAD_SUBTRACT:
			controller->zoomOut();
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
	controller->m3DFrame->SetFocus();
	static int lx = 0, ly = 0;
	if (evt.RightDown()){
		lx = evt.GetX();
		ly = evt.GetY();
		movingCamera = true;
	}

	if (!evt.RightIsDown()) {
		movingCamera = false;
	}
	
	if (movingCamera){
		int x = evt.GetX();
		int y = evt.GetY();
		int xdif = (x - lx);
		int ydif = (y - ly);
		mRotX = Ogre::Degree(xdif * mRotate);
		mRotY = Ogre::Degree(ydif * mRotate);
		lx = x;
		ly = y;
		moveCamera();
	}
}

CameraManager::~CameraManager ()
{
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	Ogre::Vector3 direction = mCamera->getDirection();
	Ogre::Vector3 position = camNode->getPosition();
	[d setObject: [NSString stringWithFormat: @"%f", direction.x] 
		forKey: @"cameraDirection-X"];
	[d setObject: [NSString stringWithFormat: @"%f", direction.y] 
		forKey: @"cameraDirection-Y"];
	[d setObject: [NSString stringWithFormat: @"%f", direction.z] 
		forKey: @"cameraDirection-Z"];
	[d setObject: [NSString stringWithFormat: @"%f", position.x] 
		forKey: @"cameraPosition-X"];
	[d setObject: [NSString stringWithFormat: @"%f", position.y] 
		forKey: @"cameraPosition-Y"];
	[d setObject: [NSString stringWithFormat: @"%f", position.z] 
		forKey: @"cameraPosition-Z"];
	[d synchronize];

	mSceneMgr->destroyAllCameras();
	mRenderWindow->removeAllViewports();
}

CameraManager::CameraManager (CommunicationPatternWindow *c,
				Ogre::RenderWindow *win)
{
	controller = c;
	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

	Ogre::Vector3 position, direction;
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

	NSString *dx, *dy, *dz;
	NSString *px, *py, *pz;
	dx = [d stringForKey: @"cameraDirection-X"];
	dy = [d stringForKey: @"cameraDirection-Y"];
	dz = [d stringForKey: @"cameraDirection-Z"];
	px = [d stringForKey: @"cameraPosition-X"];
	py = [d stringForKey: @"cameraPosition-Y"];
	pz = [d stringForKey: @"cameraPosition-Z"];

	if (dx && dy && dz && px && py && pz){
		direction = Ogre::Vector3([dx doubleValue], [dy doubleValue], [dz doubleValue]);
		position = Ogre::Vector3([px doubleValue], [py doubleValue], [pz doubleValue]);
	}else{
		direction = Ogre::Vector3 (-0.529813,-0.662266, -0.529813);
		position = Ogre::Vector3 (500,500,500);
	}

	createCamera (position, direction);
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

void CameraManager::cameraForward ()
{
        mDirection.z -= mMove;
        moveCamera();
}

void CameraManager::cameraBackward ()
{
        mDirection.z += mMove;
        moveCamera();
}

void CameraManager::cameraLeft ()
{
        mDirection.x -= mMove;
        moveCamera();
}

void CameraManager::cameraRight ()
{
        mDirection.x += mMove;
        moveCamera();
}

void CameraManager::cameraUp ()
{
        mDirection.y += mMove;
        moveCamera();
}

void CameraManager::cameraDown ()
{
        mDirection.y -= mMove;
        moveCamera();
}

