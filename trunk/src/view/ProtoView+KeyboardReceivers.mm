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
@end
