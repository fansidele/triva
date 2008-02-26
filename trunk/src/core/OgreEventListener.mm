#include "OgreEventListener.h"

OgreEventListener::OgreEventListener (id v)
{
	view = v;
}

void OgreEventListener::onCharEvent (wxKeyEvent& evt)
{
	std::cout << __FUNCTION__ << std::endl;
}

void OgreEventListener::onKeyDownEvent(wxKeyEvent& evt)
{
	std::cout << __FUNCTION__ << std::endl;
	std::cout << "#: " << evt.GetKeyCode() << std::endl;
	[view keyEvent: &evt];
}


void OgreEventListener::onKeyUpEvent(wxKeyEvent& evt)
{
	std::cout << __FUNCTION__ << std::endl;
}

void OgreEventListener::onMouseEvent(wxMouseEvent& evt)
{
	std::cout << __FUNCTION__ << std::endl;
}

void OgreEventListener::onWindowSize(wxSizeEvent& evt)
{
	std::cout << __FUNCTION__ << std::endl;
}

