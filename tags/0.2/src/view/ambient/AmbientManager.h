#ifndef __AMBIENT_MANAGER_H
#define __AMBIENT_MANAGER_H

#include <Ogre.h>
#include "view/ambient/Origin.h"

class AmbientManager : public Ogre::FrameListener,
	public Ogre::WindowEventListener
{
/*
	bool keyPressed (const OIS::KeyEvent& e);
	bool keyReleased (const OIS::KeyEvent& e);
	bool mouseMoved(const OIS::MouseEvent &m);
	bool mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b);
	bool mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b);

*/
public:
	AmbientManager ();
	~AmbientManager ();

private:
	bool frameStarted (const Ogre::FrameEvent& evt);
	bool frameEnded (const Ogre::FrameEvent& evt);

	void createAxes(int size);
	void createPlane (int sideSize);

//	void assimilateEvent (const Ogre::FrameEvent& evt);

//	void createRect (Ogre::SceneNode *itsnode, const char *name, Ogre::Vector3 size, Ogre::Vector3 pos);
//	void changeRect (Ogre::SceneNode *itsnode, Ogre::Vector3 size, Ogre::Vector3 pos);
//	void createMachine (const char *machine);
//	void createThread (const char *machine, const char *thread);

private:
	Ogre::Root *mRoot;
	Ogre::SceneManager* mSceneMgr;

	Origin origin;

	/* for Y scale stuff - initial scale is 1 second for 1 ogre point */
	double yScale; // = 1; defined in constructor
	double yScaleChangeFactor; // = 0.1; defined in constructor

	/* for place scale stuff */
	double planeScale;
	double planeScaleChangeFactor;
	bool changingPlaneScale;
};

#endif
