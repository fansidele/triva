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

///enum ProtoApplicationState {Initialized,Configured,Running,Paused};

@interface ProtoView  : ProtoComponent
{
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;

	DrawManager *drawManager;
	/* for labels appearence */
	bool statesLabelsAppearance;
	bool containersLabelsAppearance;
	XContainer *root; //not retained (modified in View and in Simulator)
}

- (void) changePositionAlgorithm;
- (void) switchStatesLabels;
- (void) switchContainersLabels;
- (bool) statesLabelsAppearance;
- (bool) containersLabelsAppearance;
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

#endif
