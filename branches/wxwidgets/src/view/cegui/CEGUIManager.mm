#include "CEGUIManager.h"

#ifndef TRIVAWXWIDGETS

static CEGUI::MouseButton convertButton(int buttonID)
{   
        using namespace OIS; 
        switch (buttonID)
        {
                case OIS::MB_Left:
                        return CEGUI::LeftButton;
                case OIS::MB_Right:
                        return CEGUI::RightButton;
                case OIS::MB_Middle:
                        return CEGUI::MiddleButton;
                // Not sure what to do with this one...
                //   case MouseEvent::BUTTON3_MASK:
                //   return CEGUI::X1Button;
                default:
                        return CEGUI::LeftButton;
        }
}   

CEGUIManager::CEGUIManager (ProtoView *view, Ogre::RenderWindow *mWindow, Ogre::SceneManager *mSceneMgr)
{
	viewController = view;
	[viewController retain];

	mShutdown = false;

	mRenderer = new CEGUI::OgreCEGUIRenderer(mWindow, Ogre::RENDER_QUEUE_OVERLAY, false, 3000, mSceneMgr);
	mSystem = new CEGUI::System(mRenderer);

	CEGUI::SchemeManager::getSingleton().loadScheme((CEGUI::utf8*)"WindowsLook.scheme");

	mSystem->setDefaultMouseCursor((CEGUI::utf8*)"WindowsLook", (CEGUI::utf8*)"MouseArrow");

	CEGUI::FontManager::getSingleton().createFont("bluehighway-12.font");

	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window* myRoot = win->loadWindowLayout("pilcha.layout");
	CEGUI::System::getSingleton().setGUISheet(myRoot);

	NSLog (@"####");
	this->configureControlWindow();

	//about
	CEGUI::Window *about = win->getWindow("about");
	about->subscribeEvent(CEGUI::PushButton::EventClicked,CEGUI::Event::Subscriber(&CEGUIManager::about, this));
	win->getWindow ("aboutWindow")->setVisible(0);

	//exit
	win->getWindow ("exit")->subscribeEvent(CEGUI::PushButton::EventClicked,CEGUI::Event::Subscriber(&CEGUIManager::quit, this));

	//load bundles
	win->getWindow ("loadBundles")->subscribeEvent(CEGUI::PushButton::EventClicked,CEGUI::Event::Subscriber(&CEGUIManager::loadBundle, this));


	this->updateScale ();
}

CEGUIManager::~CEGUIManager ()
{
	[viewController release];
}

bool CEGUIManager::frameStarted (const Ogre::FrameEvent& evt)
{

	if ( CEGUI::System::getSingletonPtr() ){
		CEGUI::System::getSingleton().injectTimePulse(evt.timeSinceLastFrame );
	}

	return !mShutdown;
}

bool CEGUIManager::keyPressed( const OIS::KeyEvent &e ) 
{
	CEGUI::System *sys = CEGUI::System::getSingletonPtr();
	sys->injectKeyDown(e.key);
	sys->injectChar(e.text);
	return true;
}

bool CEGUIManager::keyReleased( const OIS::KeyEvent &e ) 
{
	CEGUI::System::getSingleton().injectKeyUp(e.key);
	return true;
}

bool CEGUIManager::mousePressed (const OIS::MouseEvent &e, OIS::MouseButtonID
id)
{
	CEGUI::System::getSingleton().injectMouseButtonDown(convertButton(id));
	return true;
}

bool CEGUIManager::mouseReleased( const OIS::MouseEvent &e, OIS::MouseButtonID
id )
{
	CEGUI::System::getSingleton().injectMouseButtonUp(convertButton(id));
	return true;
}


bool CEGUIManager::mouseMoved( const OIS::MouseEvent &e )
{
	CEGUI::System::getSingleton().injectMouseMove(e.state.X.rel,e.state.Y.rel);
	return true;
}

bool CEGUIManager::quit(const CEGUI::EventArgs &e)
{
	mShutdown = true;
	return true;
}


bool CEGUIManager::about (const CEGUI::EventArgs &e)
{
	std::cout << "Key: " << std::endl;
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window *about = win->getWindow("aboutWindow");
	about->setVisible(1);
	about->subscribeEvent(CEGUI::FrameWindow::EventCloseClicked,CEGUI::Event::Subscriber(&CEGUIManager::aboutWindow, this));
	return true;
}

bool CEGUIManager::aboutWindow (const CEGUI::EventArgs &e)
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window *about = win->getWindow("aboutWindow");
	about->setVisible(0);
	return true;
}

bool CEGUIManager::loadBundle (const CEGUI::EventArgs &e)
{
	this->resetLoadBundleMenu();
	[viewController loadBundles];
	CEGUI::PopupMenu* popupMenu = (CEGUI::PopupMenu*)CEGUI::WindowManager::getSingleton().getWindow("loadBundlesAutoPopup");
	return true;
}

bool CEGUIManager::loadBundleItem (const CEGUI::EventArgs &e)
{
	CEGUI::WindowEventArgs *x = (CEGUI::WindowEventArgs *)&e;
	CEGUI::MenuItem *m = (CEGUI::MenuItem*)x->window;
	[viewController loadBundleNamed: [NSString stringWithFormat: @"%s",
m->getText().c_str()]];
	return true;
}

void CEGUIManager::resetLoadBundleMenu ()
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window *menuLoadBundles = win->getWindow ("loadBundlesAutoPopup");
	unsigned int i;
	for (i = 0; i < menuLoadBundles->getChildCount(); i++){
		CEGUI::Window *sub = menuLoadBundles->getChild (i);
		menuLoadBundles->removeChildWindow (sub);
	}
}

void CEGUIManager::addBundleMenu (std::string newentry)
{
	CEGUI::PopupMenu* popupMenu = (CEGUI::PopupMenu*)CEGUI::WindowManager::getSingleton().getWindow("loadBundlesAutoPopup");
	CEGUI::Window* menuitem = CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/MenuItem");
	menuitem->setText (newentry);
	menuitem->subscribeEvent(CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber(&CEGUIManager::loadBundleItem, this));
	popupMenu->addChildWindow(menuitem);
}

#endif //TRIVAWXWIDGETS
