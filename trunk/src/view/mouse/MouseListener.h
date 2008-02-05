#ifndef __MOUSELISTENER_H
#define __MOUSELISTENER_H

#include <Ogre.h>
#include <OIS.h>
#include "view/ProtoView.h"

class MouseListener : public OIS::MouseListener
{
        bool mouseMoved(const OIS::MouseEvent &m);
        bool mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b);
        bool mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b);


private:
        ProtoView *viewController;


public: 
	MouseListener (ProtoView *view) { viewController = view; [viewController retain];};
	~MouseListener (){};
};

#endif
