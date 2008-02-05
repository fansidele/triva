#include "ExitManager.h"

ExitManager::ExitManager ()
{
	mShutdown = false;
}

ExitManager::~ExitManager ()
{
}

bool ExitManager::keyPressed( const OIS::KeyEvent &e ) 
{
        if (e.key == OIS::KC_ESCAPE) {
		std::cout << "KC_ESCAPE detected" << std::endl;
		mShutdown = true;
	}
	return true;
}

bool ExitManager::keyReleased( const OIS::KeyEvent &e ) 
{
	return true;
}

bool ExitManager::frameStarted (const Ogre::FrameEvent& evt)
{
	return !mShutdown;	
}
