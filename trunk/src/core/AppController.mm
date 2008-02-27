#include "AppController.h"

IMPLEMENT_APP(ProtoController);

bool ProtoController::OnInit()
{
	pool = [[NSAutoreleasePool alloc] init];
	ogreConfigure = [[OgreConfigure alloc] init];

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

