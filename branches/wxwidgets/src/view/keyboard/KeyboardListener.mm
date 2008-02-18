#include "view/keyboard/KeyboardListener.h"

bool KeyboardListener::keyPressed (const OIS::KeyEvent &e) 
{ 
	switch (e.key){
		case OIS::KC_P:
			[viewController keyboardP];
			break;
		case OIS::KC_O:
			[viewController keyboardO];
			break;
		case OIS::KC_B:
			[viewController keyboardB];
			break;
		case OIS::KC_F:
			[viewController keyboardF];
			break;
		case OIS::KC_G:
			[viewController keyboardG];
			break;
		case OIS::KC_V:
			[viewController keyboardV];
			break;
		case OIS::KC_L:
			[viewController keyboardL];
			break;
		case OIS::KC_K:
			[viewController keyboardK];
			break;
		case OIS::KC_M:
			[viewController keyboardM];
			break;
/*
		case OIS::KC_M:
			break;
		case OIS::KC_E:
			break;
		case OIS::KC_Q:
			break;
		case OIS::KC_W:
			break;
		case OIS::KC_S:
			break;
		case OIS::KC_A:
			break;
		case OIS::KC_D:
			break;
		case OIS::KC_J:
			break;
		case OIS::KC_K:
			break;
		case OIS::KC_L:
			break;
		case OIS::KC_PERIOD:
			break;
		case OIS::KC_COMMA:
			break;
		case OIS::KC_ADD:
			break;
		case OIS::KC_SUBTRACT:
			break;
		case OIS::KC_N:
			break;
*/
		default:
			printf ("%x\n", e.key);
			break;
	}
	return true; 
}

bool KeyboardListener::keyReleased (const OIS::KeyEvent &e) 
{ 
/*
	switch (e.key){
		case OIS::KC_P:
			[viewController zoomOut];
			break;
		case OIS::KC_O:
			[viewController zoomIn];
			break;
		default:
			break;
	}
	switch (e.key){
		case OIS::KC_E:
			break;
		case OIS::KC_Q:
			break;
		case OIS::KC_W:
			break;
		case OIS::KC_S:
			break;
		case OIS::KC_A:
			break;
		case OIS::KC_D:
			break;
		default:
			break;
	}
*/
	return true; 
}

bool KeyboardListener::mouseMoved(const OIS::MouseEvent &m)
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

bool KeyboardListener::mousePressed(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
        return true;
}

bool KeyboardListener::mouseReleased(const OIS::MouseEvent &m,OIS::MouseButtonID b)
{
        return true;
}

