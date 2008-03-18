#include "TrivaController.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

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
NS_DURING
//	[trivaPaje readNextChunk:nil];
//	NSLog (@"retornou");
//	[trivaPaje readNextChunk:nil];
//	[trivaPaje readNextChunk:nil];

NS_HANDLER
        NSLog (@"Exception = %@", localException);
        wxString m = NSSTRINGtoWXSTRING ([localException reason]);
        wxString n = NSSTRINGtoWXSTRING ([localException name]);
        wxMessageDialog *dial = new wxMessageDialog(NULL, m, n, wxOK | wxICON_ERROR);
        dial->ShowModal();
NS_ENDHANDLER
//	NSLog (@"passou a rotina de tratamento %@\n", nil);
}

void TrivaController::applicationIsPaused()
{
	std::cout << __FUNCTION__ << std::endl;
	readTimer.Stop();
//	m3DFrame->pauseRenderTimer();
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
