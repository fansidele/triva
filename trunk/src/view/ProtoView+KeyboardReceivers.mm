#include "ProtoView.h"

@implementation ProtoView (KeyboardReceivers)
- (void) keyboardP
{
//	[self zoomOut];
}

- (void) keyboardO
{
//	[self zoomIn];
}

- (void) keyboardB
{
	[self zoomSwitch];
}

- (void) keyboardF
{
	NSLog (@"%s", __FUNCTION__);
	[self fullscreenSwitch];
}

- (void) keyboardG
{
	[self changePositionAlgorithm];
}

- (void) keyboardV
{
	[self adjustZoom];
}

- (void) keyboardL
{
	[self switchStatesLabels];
}

- (void) keyboardK
{
	[self switchContainersLabels];
}

- (void) keyboardM
{
	NSLog (@"%s", __FUNCTION__);
#ifndef TRIVAWXWIDGETS
	ceguiManager->setMoveCameraButton (!movingCamera);
#endif
//	[self switchMovingCamera];
}

- (void) keyEvent: (wxKeyEvent *) ev
{
	int key = ev->GetKeyCode();
	switch (key){
		case WXK_NUMPAD8:
		case WXK_UP:
			cameraManager->moveUp();
			break;

		case WXK_NUMPAD2:
		case WXK_DOWN:
			cameraManager->moveDown();
			break;

		case WXK_NUMPAD6:
		case WXK_RIGHT:
			cameraManager->moveRight();
			break;

		case WXK_NUMPAD4:
		case WXK_LEFT:
			cameraManager->moveLeft();
			break;

		default:
			break;
	}
	
}
@end
