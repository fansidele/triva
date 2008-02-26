#ifndef __CAMERA2_MANAGER_H
#define __CAMERA2_MANAGER_H

#include "core/wxOgreRenderWindow.h"
#include <Ogre.h>
#include "view/QueryFlags.h"

class Camera2Manager : public wxInputEventListener,
			public Ogre::FrameListener
{
public: 
	Camera2Manager (Ogre::RenderWindow *win);
	Camera2Manager ();
	~Camera2Manager ();

protected:
	void onKeyDownEvent(wxKeyEvent& evt);
	void onKeyUpEvent(wxKeyEvent& evt);
	void onMouseEvent(wxMouseEvent& evt);

	bool frameStarted (const Ogre::FrameEvent& evt);
	bool frameEnded (const Ogre::FrameEvent& evt);

	void createCamera ();
	void moveCamera ();
	void createViewport ();

	void createViewport (Ogre::RenderWindow *win);

public:
	void changeCamera ();	
	void newPositionForCamera (double time);
	void setMovingCamera (bool m);

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

};

#endif