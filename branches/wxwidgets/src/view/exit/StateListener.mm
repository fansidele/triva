#include "view/listeners/StateListener.h"

StateListener *StateListener::mStateListener;

StateListener *StateListener::getSingletonPtr ()
{
	if (!mStateListener) {
		mStateListener = new StateListener ();
	}
	return mStateListener;
}	

StateListener::StateListener ()
{
}

StateListener::~StateListener ()
{
        while (!mStates.empty()) {
                mStates.back()->exit();
                mStates.pop_back();
        }
}
bool StateListener::frameEnded (const Ogre::FrameEvent& evt)
{
	return mStates.back()->frameStarted(evt);
}

bool StateListener::frameStarted (const Ogre::FrameEvent& evt)
{
	return mStates.back()->frameEnded(evt);
}

bool StateListener::keyPressed( const OIS::KeyEvent &e ) 
{
	return mStates.back()->keyPressed(e);
}

bool StateListener::keyReleased( const OIS::KeyEvent &e ) 
{
	return mStates.back()->keyReleased(e);
}

bool StateListener::mouseMoved(const OIS::MouseEvent &m)
{
	return mStates.back()->mouseMoved (m);
}

bool StateListener::mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
	return mStates.back()->mousePressed (m, b);
}

bool StateListener::mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
	return mStates.back()->mouseReleased (m, b);
}

/*
 * for states
 */
bool StateListener::changeState(AppState* state)
{
        // cleanup the current state
        if ( !mStates.empty() ) {
                mStates.back()->exit();
                mStates.pop_back();
        }

        // store and init the new state
        mStates.push_back(state);
        mStates.back()->enter();
        return true;
}

bool StateListener::pushState(AppState* state)
{
        // pause current state
        if ( !mStates.empty() ) {
                mStates.back()->pause();
        }

        // store and init the new state
        mStates.push_back(state);
        mStates.back()->enter();
        return true;
}

bool StateListener::popState()
{
        // cleanup the current state
        if ( !mStates.empty() ) {
                mStates.back()->exit();
                mStates.pop_back();
        }

        // resume previous state
        if ( !mStates.empty() ) {
                mStates.back()->resume();
        }
        return true;
}

