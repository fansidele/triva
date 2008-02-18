#ifndef __CEGUI_MANAGER_H
#define __CEGUI_MANAGER_H

#ifndef TRIVAWXWIDGETS

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
	CEGUI::System *mSystem;
	CEGUI::OgreCEGUIRenderer *mRenderer;
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
	bool quit(const CEGUI::EventArgs &e);
	bool about (const CEGUI::EventArgs &e);
	bool aboutWindow (const CEGUI::EventArgs &e);
	bool loadBundle (const CEGUI::EventArgs &e);

	//control window related

	//To update CEGUI elements

	//bundle related
	void resetLoadBundleMenu ();
	void addBundleMenu (std::string newentry);
	bool loadBundleItem (const CEGUI::EventArgs &e);

	//CEGUIManager+ControlWindow
	void configureControlWindow();
	bool moveCamera (const CEGUI::EventArgs &e);
	bool scaleval (const CEGUI::EventArgs &e);
	bool scalein (const CEGUI::EventArgs &e);
	bool scaleout (const CEGUI::EventArgs &e);
	void updateScale ();
	void setInfoPanelText (std::string s);
	void setMoveCameraButton (bool m);
	bool controlButton(const CEGUI::EventArgs &e);
	void setControlButtonText (std::string s);
	bool hideControlWindow ();
	bool hideControlWindow (const CEGUI::EventArgs &e);
	bool showControlWindow ();
	bool showControlWindow (const CEGUI::EventArgs &e);
	

	//CEGUIManager+BundleWindow
	CEGUI::Window *getWindow (std::string name);
/*
	CEGUI::Window *getBundleWindow ();
	CEGUI::Window *getComboBundleWindow ();
	CEGUI::Window *getPaneBundleWindow ();
	bool configureBundleWindow();
	bool showBundleWindow(const CEGUI::EventArgs &e);
	bool showBundleWindow();
	bool hideBundleWindow (const CEGUI::EventArgs &e);
	bool hideBundleWindow ();
*/
	bool bundleMenuOption (const CEGUI::EventArgs &e);
	bool addMenuNamed (std::string bundleName);
	bool addSubMenu (std::string bundleName, std::string option, id val);
	bool setSubMenu (std::string bundleName, std::string option, id val);

	//other
//	bool paused;

private:
	bool addSubMenu (std::string optionName, CEGUI::PopupMenu* optionPopupMenu, id val);
	bool addDictionarySubMenu (id val, std::string optionName, CEGUI::PopupMenu* p);
	bool addArraySubMenu (id val, std::string optionName, CEGUI::PopupMenu* p);
	bool addStringSubMenu (id val, std::string optionName, CEGUI::PopupMenu* p);
};

#include "view/ProtoView.h"

#endif //TRIVAWXWIDGETS

#endif
