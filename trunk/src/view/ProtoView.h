#ifndef __PROTOVIEW_H
#define __PROTOVIEW_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include <OIS.h>
#include "general/ProtoComponent.h"
#include "view/VisuInputManager.h"
#include "view/ProtoSensor.h"
#include "view/camera/CameraManager.h"
#include "view/ambient/AmbientManager.h"
#include "view/cegui/CEGUIManager.h"
#include "view/keyboard/KeyboardListener.h"
#include "view/draw/DrawManager.h"
#include "view/exit/ExitManager.h"
#include "core/ProtoController.h"
#include "ogre-simulator/XObject.h"

@class ProtoController;

@interface ProtoView  : ProtoComponent
{
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;
	VisuInputManager *mInputMgr;
	BOOL bShutdown;

	CameraManager *cameraManager;
	AmbientManager *ambientManager;
	CEGUIManager *ceguiManager;
	DrawManager *drawManager;
	ExitManager *exitManager;
	KeyboardListener *keyboardListener;

	ProtoController *applicationController;
	ProtoSensor *sensor;

	/* for visual scaling */
	bool zoomSwitch;
	double yScale;
	double yScaleChangeFactor;
	double planeScale;
	double planeScaleChangeFactor;

	/* for fullscreen control */
	double fullscreenSwitch;

	/* for labels appearence */
	bool statesLabelsAppearance;
	bool containersLabelsAppearance;

	XContainer *root; //not retained (modified in View and in Simulator)
}
/* methods called by the application controller (core/ProtoController.mm) */
- (void) setController: (ProtoController *) controller;
- (void) start;
- (void) startSession;
- (double) yScale;
- (double) yScaleChangeFactor;

- (void) setYScale: (double) y;

/* X */
- (void) zoomIn;
- (void) zoomOut;
- (void) zoomSwitch;
- (void) adjustZoom;
- (void) fullscreenSwitch;
- (void) changePositionAlgorithm;

- (void) switchStatesLabels;
- (void) switchContainersLabels;
- (bool) statesLabelsAppearance;
- (bool) containersLabelsAppearance;
@end

@interface ProtoView (KeyboardMethods)
- (void) keyboardP;
- (void) keyboardO;
- (void) keyboardB;
- (void) keyboardF;
- (void) keyboardG;
- (void) keyboardV;
- (void) keyboardL;
- (void) keyboardK;
@end


#endif
