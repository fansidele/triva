#ifndef __PROTOVIEW_H
#define __PROTOVIEW_H
#include "view/camera/CameraManager.h"
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include <OIS.h>
#include <wx/wx.h>
#include "general/ProtoComponent.h"
#include "view/ambient/AmbientManager.h"
#include "view/cegui/CEGUIManager.h"
#include "view/keyboard/KeyboardListener.h"
#include "view/mouse/MouseListener.h"
#include "view/draw/DrawManager.h"
#include "view/exit/ExitManager.h"
//#include "core/ProtoController.h"
#include "ogre-simulator/XObject.h"

@class ProtoController;

///enum ProtoApplicationState {Initialized,Configured,Running,Paused};

@interface ProtoView  : ProtoComponent
{
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;
	BOOL bShutdown;

	CameraManager *cameraManager;
	AmbientManager *ambientManager;
	DrawManager *drawManager;
	ExitManager *exitManager;
	KeyboardListener *keyboardListener;
	MouseListener *mouseListener;

	ProtoController *applicationController;

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

	BOOL paused;
	BOOL movingCamera;

	//to keep bundles configuration
	NSMutableDictionary *bundlesConfiguration;

//	ProtoApplicationState applicationState;
}
/* methods called by the application controller (core/ProtoController.mm) */
- (void) setController: (ProtoController *) controller;
- (BOOL) refresh;
- (void) end;
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
- (void) switchMovingCamera;


//fev26 2008
- (CameraManager *) cameraManager;
@end

@interface ProtoView (Selection)
- (void) selectObjectIdentifier: (NSString *) identifier;
- (void) unselectObjectIdentifier: (NSString *) identifier; 
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
- (void) keyboardM;
- (void) onKeyDownEvent: (wxKeyEvent *) ev;
- (void) onKeyUpEvent: (wxKeyEvent *) ev;
@end

/*
@interface ProtoView (States)
- (void) setState: (enum ProtoApplicationState) newState;
- (enum ProtoApplicationState) currentState;
- (void) controlButton;
- (BOOL) isPaused;
@end
*/
#endif
