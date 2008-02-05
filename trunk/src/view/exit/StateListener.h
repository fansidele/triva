#ifndef __STATE_LISTENER_H
#define __STATE_LISTENER_H

#include <Ogre.h>
#include <OIS.h>


class AppState;

class StateListener : 
	public Ogre::FrameListener,
	public Ogre::WindowEventListener,
	public OIS::KeyListener,
	public OIS::MouseListener
{
private:

public:
	StateListener ();
	~StateListener ();
	static StateListener *getSingletonPtr ();

	//From Ogre::FrameListener
	bool frameStarted (const Ogre::FrameEvent& evt);
	bool frameEnded (const Ogre::FrameEvent& evt);

	//From OIS::KeyListener
	bool keyPressed( const OIS::KeyEvent &e);
        bool keyReleased( const OIS::KeyEvent &e);

	//From OIS::MouseListener
	bool mouseMoved(const OIS::MouseEvent&);
	bool mousePressed(const OIS::MouseEvent&, OIS::MouseButtonID);
	bool mouseReleased(const OIS::MouseEvent&, OIS::MouseButtonID);

private:
	std::vector<AppState*> mStates;
	static StateListener *mStateListener;

public:
	bool changeState (AppState *state);
	bool pushState (AppState *state);
	bool popState ();
};

#include "view/states/AppState.h"

#endif
