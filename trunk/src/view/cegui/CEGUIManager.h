#ifndef __CEGUI_MANAGER_H
#define __CEGUI_MANAGER_H

#include <Ogre.h>
#include <OIS.h>
#include <CEGUI.h>
#include <OgreCEGUIRenderer.h>

@class ProtoView;

class CEGUIManager : 
	public Ogre::FrameListener,
	public OIS::KeyListener,
	public OIS::MouseListener
{
private:
	CEGUI::Window *root;

	CEGUI::System *mSystem;
	CEGUI::OgreCEGUIRenderer *mRenderer;
	CEGUI::Window *startButton;
	CEGUI::Window *quitButton;
	CEGUI::Window *pauseButton;
	CEGUI::Checkbox *moveCameraButton;
	CEGUI::Window *scaleText;
	CEGUI::Window *infoPanel;
	bool mShutdown;

	ProtoView *viewController;
	

public:
	CEGUIManager(ProtoView *view, Ogre::RenderWindow *mWindow,Ogre::SceneManager *mSceneMgr);
	~CEGUIManager ();

	//From Ogre::FrameListener
	bool frameStarted (const Ogre::FrameEvent& evt);

	//From OIS::KeyListener
	bool keyPressed( const OIS::KeyEvent &e);
        bool keyReleased( const OIS::KeyEvent &e);

	//From OIS::MouseListener
	bool mousePressed (const OIS::MouseEvent &e, OIS::MouseButtonID id);
	bool mouseReleased( const OIS::MouseEvent &e, OIS::MouseButtonID id );
	bool mouseMoved( const OIS::MouseEvent &e );

	//For CEGUI Event Callbacks
	bool bar(const CEGUI::EventArgs &e);
	bool quit(const CEGUI::EventArgs &e);
	bool startSession(const CEGUI::EventArgs &e);
	bool pause (const CEGUI::EventArgs &e);
	bool moveCamera (const CEGUI::EventArgs &e);
	bool keyDown (const CEGUI::EventArgs &e);

	bool scaleval (const CEGUI::EventArgs &e);
	bool scalein (const CEGUI::EventArgs &e);
	bool scaleout (const CEGUI::EventArgs &e);
	void updateScale ();

	//To update CEGUI elements
	void setInfoPanelText (std::string s);
	void setMoveCameraButton (bool m);

	bool paused;
};

#include "view/ProtoView.h"

#endif
