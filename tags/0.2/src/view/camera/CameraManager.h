#ifndef __CAMERA2_MANAGER_H
#define __CAMERA2_MANAGER_H

#include "view/wxInputEventListener.h"
#include <Ogre.h>
#include "view/QueryFlags.h"

class TrivaController;

class CameraManager : public wxInputEventListener,
			public Ogre::FrameListener
{
public: 
	CameraManager (TrivaController *c, Ogre::RenderWindow *win);
	~CameraManager ();
	void setMovingCamera (bool c){ movingCamera = c; };
	void cameraForward ();
	void cameraBackward ();
	void cameraLeft ();
	void cameraRight ();
	void cameraUp ();
	void cameraDown ();

protected:
	void onKeyDownEvent(wxKeyEvent& evt);
	void onKeyUpEvent(wxKeyEvent& evt);
	void onMouseEvent(wxMouseEvent& evt);

	bool frameStarted (const Ogre::FrameEvent& evt);
	bool frameEnded (const Ogre::FrameEvent& evt);

	void createCamera ();
	void moveCamera ();
	void createViewport (Ogre::RenderWindow *win);

private:
	Ogre::Radian mRotX, mRotY;
	Ogre::Vector3 mDirection;
	Ogre::Real mRotate;
	Ogre::Real mMove;
	Ogre::Viewport* mViewport;
	Ogre::Camera* mCamera;
	bool movingCamera;

        Ogre::Root *mRoot;
        Ogre::SceneManager* mSceneMgr;
	Ogre::RenderWindow *mRenderWindow;

	TrivaController *controller;
};

#include "view/TrivaController.h"
#endif
