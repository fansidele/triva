#include "CEGUIManager.h"

#ifndef TRIVAWXWIDGETS

void CEGUIManager::configureControlWindow ()
{
	//callbacks
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	win->getWindow("controlButton")->subscribeEvent(CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber(&CEGUIManager::controlButton, this));
	win->getWindow("movecamera")->subscribeEvent (CEGUI::Checkbox::EventCheckStateChanged, CEGUI::Event::Subscriber (&CEGUIManager::moveCamera, this));
	win->getWindow("yscale/in")->subscribeEvent (CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber (&CEGUIManager::scalein, this));
	win->getWindow("yscale/out")->subscribeEvent (CEGUI::PushButton::EventClicked, CEGUI::Event::Subscriber (&CEGUIManager::scaleout, this));
	win->getWindow("yscale/val")->subscribeEvent (CEGUI::Editbox::EventTextAccepted, CEGUI::Event::Subscriber (&CEGUIManager::scaleval, this));
//	win->getWindow("controlWindow")->subscribeEvent(CEGUI::FrameWindow::EventCloseClicked,CEGUI::Event::Subscriber(&CEGUIManager::hideControlWindow, this));
	this->hideControlWindow ();
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

bool CEGUIManager::controlButton (const CEGUI::EventArgs &e)
{
	[viewController controlButton];
	return true;
}

void CEGUIManager::setInfoPanelText (std::string s)
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	win->getWindow("info")->setText(s);
}

void CEGUIManager::setControlButtonText (std::string s)
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	win->getWindow("controlButton")->setText(s);
}

bool CEGUIManager::moveCamera (const CEGUI::EventArgs &e)
{
	[viewController switchMovingCamera];
	return true;
}

void CEGUIManager::setMoveCameraButton (bool m)
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Checkbox *b = (CEGUI::Checkbox*)win->getWindow("movecamera");
	b->setSelected (m);
}

bool CEGUIManager::hideControlWindow (const CEGUI::EventArgs &e)
{
	return this->hideControlWindow();
}

bool CEGUIManager::showControlWindow (const CEGUI::EventArgs &e)
{
	return this->showControlWindow();
}

bool CEGUIManager::hideControlWindow ()
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window *var = win->getWindow("controlWindow");
	var->setVisible(0);
	return true;
}

bool CEGUIManager::showControlWindow ()
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	CEGUI::Window *var = win->getWindow("controlWindow");
	var->setVisible(1);
	return true;
}

#endif
