#ifndef __EXIT_MANAGER_H
#define __EXIT_MANAGER_H

#include <Ogre.h>
#include <OIS.h>

class ExitManager : 
	public OIS::KeyListener,
	public Ogre::FrameListener
{
private:
	bool mShutdown;

public:
	ExitManager ();
	~ExitManager ();

	//From OIS::KeyListener
	bool keyPressed( const OIS::KeyEvent &e);
        bool keyReleased( const OIS::KeyEvent &e);

	//From Ogre::FrameListener
	bool frameStarted (const Ogre::FrameEvent& evt);
};

#endif
