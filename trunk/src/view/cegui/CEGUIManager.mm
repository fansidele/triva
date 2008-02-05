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


	CEGUI::Window *quit = win->getWindow ("quit");
	if (quit){
		quit->subscribeEvent(CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber(&CEGUIManager::quit, this));
	}
	CEGUI::Window *start = win->getWindow ("start");
	if (start){
		start->subscribeEvent(CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber(&CEGUIManager::startSession, this));
	}
	CEGUI::Window *pause = win->getWindow ("pause");
	if (pause){
		pause->subscribeEvent(CEGUI::PushButton::EventClicked,
CEGUI::Event::Subscriber(&CEGUIManager::pause, this));	
	}
	CEGUI::Window *scalein = win->getWindow ("yscale/in");
	CEGUI::Window *scaleout= win->getWindow ("yscale/out");
	scalein->subscribeEvent (CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber (&CEGUIManager::scalein, this));
	scaleout->subscribeEvent (CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber (&CEGUIManager::scaleout, this));

	CEGUI::Window *scaleval = win->getWindow ("yscale/val");
	scaleval->subscribeEvent (CEGUI::Editbox::EventTextAccepted,
CEGUI::Event::Subscriber (&CEGUIManager::scaleval, this));

	this->updateScale ();

/*
	CEGUI::ProgressBar *bar = (CEGUI::ProgressBar *)win->getWindow ("bar");
	if (bar){
		bar->setProgress (0.6);
		bar->subscribeEvent (CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber (&CEGUIManager::bar, this));
	}
*/

/*
	CEGUI::Slider *slider = (CEGUI::Slider *)win->getWindow ("slider");
	if (slider){
		slider->subscribeEvent (CEGUI::Slider::EventValueChanged,
CEGUI::Event::Subscriber (&CEGUIManager::slider, this));
	}else{
		std::cout << "slider null" << std::endl;
	}
*/

/*
        CEGUI::Window *sheet = win->createWindow("DefaultGUISheet", "CEGUIDemo/Sheet");

        CEGUI::Window *quit = win->createWindow("TaharezLook/Button", "CEGUIDemo/QuitButton");
        quit->setText("Quit");
        quit->setSize(CEGUI::UVector2(CEGUI::UDim(0.15, 0), CEGUI::UDim(0.05, 0)));

        sheet->addChildWindow(quit);

	start = win->createWindow ("TaharezLook/Button","CEGUIDemo/StartSessionButton");
	start->setText ("Start");
	start->setSize (CEGUI::UVector2(CEGUI::UDim(0.15, 0), CEGUI::UDim(0.05, 0)));
	start->setPosition (CEGUI::UVector2(CEGUI::UDim(0.15,0),CEGUI::UDim(0,0)));

	sheet->addChildWindow (start);

pauseButton = win->createWindow ("TaharezLook/Button","CEGUIDemo/PauseButton");
pauseButton->setText ("Pause");
	paused = false;
pauseButton->setSize (CEGUI::UVector2(CEGUI::UDim(0.15, 0), CEGUI::UDim(0.05, 0)));
pauseButton->setPosition (CEGUI::UVector2(CEGUI::UDim(0,0),CEGUI::UDim(0.15,0)));
sheet->addChildWindow (pauseButton);



	scaleText = win->createWindow ("TaharezLook/Button","CEGUIDemo/ScaleText");
	scaleText->setSize (CEGUI::UVector2(CEGUI::UDim(0.10, 0), CEGUI::UDim(0.02, 0)));	
	scaleText->setPosition ((CEGUI::UVector2(CEGUI::UDim(0,0),CEGUI::UDim(0.30,0))));
	sheet->addChildWindow (scaleText);




        mSystem->setGUISheet(sheet);

*/

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
//		pauseButton->setText ("Pause");
		paused = true;
	}else{
//		pauseButton->setText ("Resume");
		paused = false;
	}
	return true;
}

bool CEGUIManager::startSession(const CEGUI::EventArgs &e)
{
	[viewController startSession];
//	start->setVisible (0);
	return true;
}
