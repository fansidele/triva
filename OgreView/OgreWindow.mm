#include "OgreWindow.h"
#include "OgreView.h"

OgreWindow::OgreWindow( wxWindow* parent )
:
OgreWindowAuto( parent )
{
	cameraManager = new CameraManager (this, m3DFrame->getRenderWindow());
	ambientManager = new AmbientManager ();
	m3DFrame->addInputListener (cameraManager);
	m3DFrame->setRenderTimerPeriod (5,true);
	m3DFrame->setListenersEnabled (true, false);
	m3DFrame->SetFocus();
}

OgreWindow::~OgreWindow()
{
	m3DFrame->removeInputListener(cameraManager);
	delete cameraManager;
	delete ambientManager;
}

void OgreWindow::configureZoom (double pointsPerSec)
{
        ambientManager->newPointsPerSecond ([filter pointsPerSecond]);
}

void OgreWindow::zoomIn ()
{
        [filter setPointsPerSecond: ([filter pointsPerSecond] * 2)];

        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setObject: [NSString stringWithFormat: @"%f",
                                [filter pointsPerSecond]]
                forKey: @"pointsPerSecond"];
        [d synchronize];

        ambientManager->newPointsPerSecond ([filter pointsPerSecond]);
}

void OgreWindow::zoomOut ()
{
        [filter setPointsPerSecond: ([filter pointsPerSecond] / 2)];

        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setObject: [NSString stringWithFormat: @"%f",
                                [filter pointsPerSecond]]
                forKey: @"pointsPerSecond"];
        [d synchronize];

        ambientManager->newPointsPerSecond ([(OgreView*)filter pointsPerSecond]);
}
