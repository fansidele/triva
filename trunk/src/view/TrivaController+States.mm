#include "TrivaController.h"

void TrivaController::applicationIsInitialized()
{
	std::cout << __FUNCTION__ << std::endl;
}

void TrivaController::applicationIsConfigured()
{
	std::cout << __FUNCTION__ << std::endl;
}

void TrivaController::applicationIsRunning()
{
	std::cout << __FUNCTION__ << std::endl;
	readTimer.SetOwner(this);
	bool x =readTimer.Start(100,wxTIMER_CONTINUOUS); /* TODO: make 1 second configurable */
	std::cout << "start result if " << x << std::endl;
	this->Connect (wxID_ANY, wxEVT_TIMER, wxTimerEventHandler(TrivaController::checkRead));
	m3DFrame->resumeRenderTimer();
}

void TrivaController::applicationIsPaused()
{
	std::cout << __FUNCTION__ << std::endl;
	readTimer.Stop();
	m3DFrame->pauseRenderTimer();
}

void TrivaController::setState (TrivaApplicationState newState)
{
	applicationState = newState;
	switch (applicationState){
		case Initialized:
			this->applicationIsInitialized();
			break;
		case Configured:
			this->applicationIsConfigured();
			break;
		case Running:
			this->applicationIsRunning();
			break;
		case Paused:
			this->applicationIsPaused();
			break;
	}
}

TrivaApplicationState TrivaController::currentState()
{
	return applicationState;
}
