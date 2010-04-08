#ifndef __CAMERA2_MANAGER_H
#define __CAMERA2_MANAGER_H

#include "wxInputEventListener.h"
#undef TRUE
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "QueryFlags.h"
#include "Triva3DFrame.h"

class OgreWindow;

class CameraManager : public wxInputEventListener
{
public: 
	CameraManager (OgreWindow *c, Ogre::RenderWindow *win);
	~CameraManager ();
//	void setMovingCamera (bool c){ movingCamera = c; };
	void cameraForward ();
	void cameraBackward ();
	void cameraLeft ();
	void cameraRight ();
	void cameraUp ();
	void cameraDown ();
	void moveCameraToY (float y);
	float getYPosition ();

protected:
	void onKeyDownEvent(wxKeyEvent& evt);
	void onKeyUpEvent(wxKeyEvent& evt);
	void onMouseEvent(wxMouseEvent& evt);

	void createCamera (Ogre::Vector3 position, Ogre::Vector3 direction);
	void moveCamera ();
	void createViewport (Ogre::RenderWindow *win);

private:
	Ogre::Radian mRotX, mRotY;
	Ogre::Vector3 mDirection;
	Ogre::Real mRotate;
	Ogre::Real mMove;
	Ogre::Viewport* mViewport;
	Ogre::Camera* mCamera;
	Ogre::SceneNode *camNode;
	bool movingCamera;

        Ogre::Root *mRoot;
        Ogre::SceneManager* mSceneMgr;
	Ogre::RenderWindow *mRenderWindow;

	OgreWindow *controller;
};

#include "OgreWindow.h"
#endif
