#include "OgreEventListener.h"

void OgreEventListener::onCharEvent (wxKeyEvent& evt)
{
	std::cout << __FUNCTION__ << std::endl;
}

void OgreEventListener::onKeyDownEvent(wxKeyEvent& evt)
{
	std::cout << __FUNCTION__ << std::endl;
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

