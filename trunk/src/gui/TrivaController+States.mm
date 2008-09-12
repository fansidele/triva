#include "TrivaController.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

void TrivaController::applicationIsInitialized()
{
	std::cout << __FUNCTION__ << std::endl;
	m3DFrame->resumeRenderTimer();
}

void TrivaController::applicationIsConfigured()
{
	std::cout << __FUNCTION__ << std::endl;
	/* read the start of event flow just to make sure we have 
	the initial paje hierarchy definition */
	wxTimerEvent event;
	this->checkRead (event);

	/* enable the possibility to open the Combined Counter Window */
	guiCombinedCounterWindow->reconfigure();
}

void TrivaController::applicationIsRunning()
{
	std::cout << __FUNCTION__ << std::endl;
	readTimer.SetOwner(this);
	bool x =readTimer.Start(10,wxTIMER_CONTINUOUS); /* TODO: make 1 second configurable */
	std::cout << "start result if " << x << std::endl;
	this->Connect (wxID_ANY, wxEVT_TIMER, wxTimerEventHandler(TrivaController::checkRead));
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
