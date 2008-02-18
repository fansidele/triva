#ifndef __MOUSELISTENER_H
#define __MOUSELISTENER_H

#include <Foundation/Foundation.h>
#include <Ogre.h>
#include <OIS.h>
#include "view/QueryFlags.h"

@class ProtoView;

class MouseListener : public OIS::MouseListener
{
        bool mouseMoved(const OIS::MouseEvent &m);
        bool mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b);
        bool mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b);


private:
        ProtoView *viewController;

	Ogre::RaySceneQuery *mRaySceneQuery;     // The ray scene query pointer
	bool mLMouseDown, mRMouseDown;     // True if the mouse buttons are down
	Ogre::MovableObject *mCurrentObject;         // The newly created object


	//debug
	Ogre::SceneNode *myManualObjectNode;
	Ogre::ManualObject *myManualObject;

public: 
	MouseListener (ProtoView *view);
	~MouseListener ();
};

//#include "view/ProtoView.h"
#endif
