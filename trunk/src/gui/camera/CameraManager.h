#ifndef __CAMERA2_MANAGER_H
#define __CAMERA2_MANAGER_H

#include "gui/wxInputEventListener.h"
#include <Ogre.h>
#include "draw/QueryFlags.h"

class TrivaController;

class CameraManager : public wxInputEventListener
{
public: 
	CameraManager (TrivaController *c, Ogre::RenderWindow *win);
	~CameraManager ();
//	void setMovingCamera (bool c){ movingCamera = c; };

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
	bool movingCamera;

        Ogre::Root *mRoot;
        Ogre::SceneManager* mSceneMgr;
	Ogre::RenderWindow *mRenderWindow;

	TrivaController *controller;
};

#include "gui/TrivaController.h"
#endif
