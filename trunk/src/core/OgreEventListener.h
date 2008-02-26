#ifndef __OgreEventListener__
#define __OgreEventListener__

#include "core/wxOgreRenderWindow.h"
#include <Ogre.h>


class OgreEventListener : public wxInputEventListener
{
private:

protected:
	void onCharEvent (wxKeyEvent& evt);
	void onKeyDownEvent(wxKeyEvent& evt);
	void onKeyUpEvent(wxKeyEvent& evt);
	void onMouseEvent(wxMouseEvent& evt);
	void onWindowSize(wxSizeEvent& evt);
};

#endif // __OgreEventListener__
