#ifndef __OgreEventListener__
#define __OgreEventListener__

#include "view/wxInputEventListener.h"
#include <Ogre.h>
#include <OIS.h>


class OgreEventListener : public wxInputEventListener
{
private:
	id view;

public:
	OgreEventListener (id v);

protected:
	void onCharEvent (wxKeyEvent& evt);
	void onKeyDownEvent(wxKeyEvent& evt);
	void onKeyUpEvent(wxKeyEvent& evt);
	void onMouseEvent(wxMouseEvent& evt);
	void onWindowSize(wxSizeEvent& evt);
};

#endif // __OgreEventListener__
