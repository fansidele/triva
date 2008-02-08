#include "CEGUIManager.h"

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

	paused = false;
	mShutdown = false;

	mRenderer = new CEGUI::OgreCEGUIRenderer(mWindow, Ogre::RENDER_QUEUE_OVERLAY, false, 3000, mSceneMgr);
	mSystem = new CEGUI::System(mRenderer);

	CEGUI::SchemeManager::getSingleton().loadScheme((CEGUI::utf8*)"WindowsLook.scheme");

	mSystem->setDefaultMouseCursor((CEGUI::utf8*)"WindowsLook", (CEGUI::utf8*)"MouseArrow");

	CEGUI::FontManager::getSingleton().createFont("bluehighway-12.font");

	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window* myRoot = win->loadWindowLayout("pilcha.layout");
	CEGUI::System::getSingleton().setGUISheet(myRoot);

	root = win->getWindow ("root");

	quitButton = win->getWindow ("quit");
	if (quitButton){
		quitButton->subscribeEvent(CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber(&CEGUIManager::quit, this));
		quitButton->subscribeEvent(CEGUI::Window::EventKeyDown, CEGUI::Event::Subscriber(&CEGUIManager::keyDown, this));
		quitButton->subscribeEvent(CEGUI::Window::EventActivated, CEGUI::Event::Subscriber(&CEGUIManager::keyDown, this));
	}
	startButton = win->getWindow ("start");
	if (startButton){
		startButton->subscribeEvent(CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber(&CEGUIManager::startSession, this));
	}
	pauseButton = win->getWindow ("pause");
	if (pauseButton){
		pauseButton->setVisible(0);
		pauseButton->subscribeEvent(CEGUI::PushButton::EventClicked,
CEGUI::Event::Subscriber(&CEGUIManager::pause, this));	
	}
	moveCameraButton = (CEGUI::Checkbox *)win->getWindow ("movecamera");
	if (moveCameraButton){
		moveCameraButton->subscribeEvent (CEGUI::Checkbox::EventCheckStateChanged, CEGUI::Event::Subscriber (&CEGUIManager::moveCamera, this));
	}
	CEGUI::Window *scalein = win->getWindow ("yscale/in");
	CEGUI::Window *scaleout= win->getWindow ("yscale/out");
	scalein->subscribeEvent (CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber (&CEGUIManager::scalein, this));
	scaleout->subscribeEvent (CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber (&CEGUIManager::scaleout, this));

	CEGUI::Window *scaleval = win->getWindow ("yscale/val");
	scaleval->subscribeEvent (CEGUI::Editbox::EventTextAccepted,
CEGUI::Event::Subscriber (&CEGUIManager::scaleval, this));

	infoPanel = win->getWindow ("info");

	//about
	CEGUI::Window *about = win->getWindow("about");
	about->subscribeEvent(CEGUI::PushButton::EventClicked,CEGUI::Event::Subscriber(&CEGUIManager::about, this));
	win->getWindow ("aboutWindow")->setVisible(0);

	win->getWindow ("exit")->subscribeEvent(CEGUI::PushButton::EventClicked,CEGUI::Event::Subscriber(&CEGUIManager::quit, this));
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

void CEGUIManager::updateScale ()
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window *scale = win->getWindow ("yscale/val");
	double y = (double)[viewController yScale];
	char str[100];
	snprintf (str, 100, "%g", y);
	scale->setText (str);
}


bool CEGUIManager::scalein (const CEGUI::EventArgs &e)
{
	[viewController zoomIn];
	return true;
}

bool CEGUIManager::scaleout (const CEGUI::EventArgs &e)
{
	[viewController zoomOut];
	return true;
}

bool CEGUIManager::scaleval (const CEGUI::EventArgs &e)
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window *scale = win->getWindow ("yscale/val");
	CEGUI::String x = scale->getText();
	double val = atof(x.c_str());
	[viewController setYScale: val];
	return true;
}

bool CEGUIManager::bar(const CEGUI::EventArgs &e)
{
//	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
//	CEGUI::ProgressBar *bar = (CEGUI::ProgressBar *)win->getWindow ("bar");


	return true;
}

bool CEGUIManager::pause (const CEGUI::EventArgs &e)
{
	if (paused == false){
		[viewController setPaused: YES];
		paused = true;
		pauseButton->setText ("Resume");
	}else{
		[viewController setPaused: NO];
		paused = false;
		pauseButton->setText ("Pause");
	}
	return true;
}

bool CEGUIManager::startSession(const CEGUI::EventArgs &e)
{
	[viewController startSession];
	pauseButton->setVisible (1);
	startButton->setVisible (0);
	return true;
}

void CEGUIManager::setInfoPanelText (std::string s)
{
	infoPanel->setText(s);
}

bool CEGUIManager::moveCamera (const CEGUI::EventArgs &e)
{
	[viewController switchMovingCamera];
	return true;
}

void CEGUIManager::setMoveCameraButton (bool m)
{
	moveCameraButton->setSelected (m);
}

bool CEGUIManager::keyDown (const CEGUI::EventArgs &e)
{
	std::cout << "Key: " << static_cast<const
CEGUI::KeyEventArgs&>(e).codepoint << std::endl;
//	CEGUI::KeyEventArgs *x = (CEGUI::KeyEventArgs*) &e;
//	const CEGUI::KeyEventArgs *x = dynamic_cast<CEGUI::KeyEventArgs>(e);
//	std::cout << "Key: " << x->codepoint << std::endl;
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
	return true;
}

void CEGUIManager::resetLoadBundleMenu ()
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window *menuLoadBundles = win->getWindow ("loadBundles");
	unsigned int i;
	for (i = 0; i < menuLoadBundles->getChildCount(); i++){
		CEGUI::Window *sub = menuLoadBundles->getChild (i);
		menuLoadBundles->removeChildWindow (sub);
	}
}
