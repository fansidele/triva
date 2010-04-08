#include "NetworkTopologyWindow.h"
#include "NetworkTopology.h"

NetworkTopologyWindow::NetworkTopologyWindow( wxWindow* parent )
:
NetworkTopologyWindowAuto( parent )
{
	cameraManager = new CameraManager (this, m3DFrame->getRenderWindow());
	ambientManager = new AmbientManager ();
	m3DFrame->addInputListener (cameraManager);
	m3DFrame->setRenderTimerPeriod (5,true);
	m3DFrame->setListenersEnabled (true, false);
	m3DFrame->SetFocus();
}

NetworkTopologyWindow::~NetworkTopologyWindow()
{
	m3DFrame->removeInputListener(cameraManager);
	delete cameraManager;
	delete ambientManager;
}

void NetworkTopologyWindow::configureZoom (double pointsPerSec)
{
        ambientManager->newPointsPerSecond ([filter pointsPerSecond]);
}

void NetworkTopologyWindow::zoomIn ()
{
        [filter setPointsPerSecond: ([filter pointsPerSecond] * 2)];

        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setObject: [NSString stringWithFormat: @"%f",
                                [filter pointsPerSecond]]
                forKey: @"pointsPerSecond"];
        [d synchronize];

        ambientManager->newPointsPerSecond ([filter pointsPerSecond]);
}

void NetworkTopologyWindow::zoomOut ()
{
        [filter setPointsPerSecond: ([filter pointsPerSecond] / 2)];

        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setObject: [NSString stringWithFormat: @"%f",
                                [filter pointsPerSecond]]
                forKey: @"pointsPerSecond"];
        [d synchronize];

        ambientManager->newPointsPerSecond ([(NetworkTopology*)filter pointsPerSecond]);
}
