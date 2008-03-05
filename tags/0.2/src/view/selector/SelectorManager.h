#ifndef __SELECTORMANAGER_H
#define __SELECTORMANAGER_H

#include "view/wxInputEventListener.h"
#include <Ogre.h>
#include "view/QueryFlags.h"
#include "view/TrivaController.h"

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
