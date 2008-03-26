#include "AppController.h"

IMPLEMENT_APP(ProtoController);

bool ProtoController::OnInit()
{
	pool = [[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];
	ogreConfigure = [[OgreConfigure alloc] init];
	if (ogreConfigure == nil){
		return false;
	}

	/* Run the GNUstep loop every 5 milliseconds (is this a good number?) */
	nsRunloopTimer.SetOwner(this);
	this->Connect (wxID_ANY, wxEVT_TIMER,wxTimerEventHandler(ProtoController::runGNUstepLoop));
	nsRunloopTimer.Start(5,wxTIMER_CONTINUOUS);

	/* Start GUI */
	TrivaController *gui = new TrivaController (0, wxID_ANY);
	gui->Show();

	return true;
}

int ProtoController::OnExit()
{
	[ogreConfigure release];
	[pool release];
	return 0;
}

void ProtoController::runGNUstepLoop(wxTimerEvent& event)
{
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate
dateWithTimeIntervalSinceNow:0.001]];
}

