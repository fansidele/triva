#include "CommunicationPatternWindow.h"
#include "CommunicationPattern.h"

CommunicationPatternWindow::CommunicationPatternWindow( wxWindow* parent )
:
CommunicationPatternWindowAuto( parent )
{
	cameraManager = new CameraManager (this, m3DFrame->getRenderWindow());
	ambientManager = new AmbientManager ();
	m3DFrame->addInputListener (cameraManager);
	m3DFrame->setRenderTimerPeriod (5,true);
	m3DFrame->setListenersEnabled (true, false);
	m3DFrame->SetFocus();
}

CommunicationPatternWindow::~CommunicationPatternWindow()
{
	m3DFrame->removeInputListener(cameraManager);
	delete cameraManager;
	delete ambientManager;
}

void CommunicationPatternWindow::configureZoom (double pointsPerSec)
{
        ambientManager->newPointsPerSecond ([filter pointsPerSecond]);
}

void CommunicationPatternWindow::zoomIn ()
{
        [filter setPointsPerSecond: ([filter pointsPerSecond] * 2)];

        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setObject: [NSString stringWithFormat: @"%f",
                                [filter pointsPerSecond]]
                forKey: @"pointsPerSecond"];
        [d synchronize];

        ambientManager->newPointsPerSecond ([filter pointsPerSecond]);
}

void CommunicationPatternWindow::zoomOut ()
{
        [filter setPointsPerSecond: ([filter pointsPerSecond] / 2)];

        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setObject: [NSString stringWithFormat: @"%f",
                                [filter pointsPerSecond]]
                forKey: @"pointsPerSecond"];
        [d synchronize];

        ambientManager->newPointsPerSecond ([(CommunicationPattern*)filter pointsPerSecond]);
}
