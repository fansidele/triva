#ifndef _TRIVA3DFRAME_H_
#define _TRIVA3DFRAME_H_

#include "wxOgreRenderWindow.h"

class Triva3DFrame : public wxOgreRenderWindow
{
private:
	Ogre::Root *mRoot;
	Ogre::SceneManager *mSceneMgr;

public:
	Triva3DFrame();
	Triva3DFrame(wxWindow *parent, wxWindowID id,
			const wxPoint &pos = wxDefaultPosition,
			const wxSize &size = wxDefaultSize,
			long style = wxSUNKEN_BORDER,
			const wxValidator &validator = wxDefaultValidator);
};

#endif
