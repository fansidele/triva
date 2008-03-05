#include "Triva3DFrame.h"

Triva3DFrame::Triva3DFrame()
{

}

Triva3DFrame::Triva3DFrame(wxWindow *parent, wxWindowID id,
                        const wxPoint &pos,
                        const wxSize &size,
                        long style,
                        const wxValidator &validator) :
	wxOgreRenderWindow(parent,id,pos,size,style,validator)
{
	createRenderWindow ();

	mRoot = Ogre::Root::getSingletonPtr ();	

	mSceneMgr = mRoot->createSceneManager(Ogre::ST_EXTERIOR_CLOSE,
				"VisuSceneManager");

}
