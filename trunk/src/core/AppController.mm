#include "AppController.h"

IMPLEMENT_APP(ProtoController);

bool ProtoController::OnInit()
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	OgreConfigure *ogreConfigure = [[OgreConfigure alloc] init];

	TrivaController *gui = new TrivaController (0, wxID_ANY);
	gui->Show();


	[ogreConfigure release];
	[pool release];
	return true;
}

