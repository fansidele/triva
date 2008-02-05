#include "view/mouse/MouseListener.h"

bool MouseListener::mouseMoved(const OIS::MouseEvent &m)
{
	int mouseFactor = m.state.Z.rel;
	if (mouseFactor != 0){
		if (mouseFactor > 0){
			[viewController zoomIn];
		}else{
			[viewController zoomOut];
		}
	}
	return true;
}

bool MouseListener::mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
        return true;
}

bool MouseListener::mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
        return true;
}

