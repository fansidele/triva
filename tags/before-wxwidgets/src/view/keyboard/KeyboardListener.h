#ifndef __KEYBOARDLISTENER_H
#define __KEYBOARDLISTENER_H

#include <Ogre.h>
#include <OIS.h>

@class ProtoView;


class KeyboardListener : public OIS::KeyListener,
		public OIS::MouseListener
{
	bool keyPressed (const OIS::KeyEvent& e);
	bool keyReleased (const OIS::KeyEvent& e);

        bool mouseMoved(const OIS::MouseEvent &m);
        bool mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b);
        bool mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b);


private:
        ProtoView *viewController;


public: 
	KeyboardListener (ProtoView *view) { viewController = view; [viewController retain];};
	~KeyboardListener (){};
};

#include "view/ProtoView.h"
#endif
