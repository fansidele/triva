#ifndef __CAMERA_MANAGER_H
#define __CAMERA_MANAGER_H

#include <Ogre.h>
#include <OIS.h>
#include "view/QueryFlags.h"

class CameraManager : public Ogre::FrameListener, 
			public Ogre::WindowEventListener,
			public OIS::KeyListener,
			public OIS::MouseListener
{
public: 
#ifdef TRIVAWXWIDGETS
	CameraManager (Ogre::RenderWindow *win);
	void moveUp();
	void moveDown();
	void moveLeft();
	void moveRight();
#endif
	CameraManager ();
	~CameraManager ();

protected:
	bool keyPressed (const OIS::KeyEvent& e);
	bool keyReleased (const OIS::KeyEvent& e);
	bool mouseMoved(const OIS::MouseEvent &m);
	bool mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b);
	bool mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b);

	bool frameStarted (const Ogre::FrameEvent& evt);
	bool frameEnded (const Ogre::FrameEvent& evt);

	void createCamera ();
	void moveCamera (const Ogre::FrameEvent& evt);
	void createViewport ();

#ifdef TRIVAWXWIDGETS
	void createViewport (Ogre::RenderWindow *win);
#endif

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
