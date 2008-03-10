#ifndef __SELECTORMANAGER_H
#define __SELECTORMANAGER_H

#include "gui/wxInputEventListener.h"
#include <Ogre.h>
#include "draw/QueryFlags.h"
#include "gui/TrivaController.h"

class TrivaController;

class SelectorManager : public wxInputEventListener
{
protected:
	void onMouseEvent(wxMouseEvent& evt);

private:
        TrivaController *controller;

	Ogre::RaySceneQuery *mRaySceneQuery;     // The ray scene query pointer
	bool mLMouseDown, mRMouseDown;     // True if the mouse buttons are down
	Ogre::MovableObject *mCurrentObject;         // The newly created object


	//debug
	Ogre::SceneNode *myManualObjectNode;
	Ogre::ManualObject *myManualObject;

public: 
	SelectorManager (TrivaController *c);
	~SelectorManager ();
};

#endif
