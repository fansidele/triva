#include "TrivaApp.h"
#include "TrivaPajeComponent.h"
#include "TrivaWindow.h"

wxString NSSTRINGtoWXSTRING (NSString *ns)
{
        if (ns == nil){
                return wxString();
        }
        return wxString::FromAscii ([ns cString]);
}

NSString *WXSTRINGtoNSSTRING (wxString wsa)
{
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return [NSString stringWithFormat:@"%s", sa];
}

std::string WXSTRINGtoSTDSTRING (wxString wsa)
{
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return std::string(sa);
}

IMPLEMENT_APP(TrivaApp)

bool TrivaApp::OnInit()
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//	TrivaWindow *window = new TrivaWindow ((wxWindow*)NULL);
//	window->setTrivaApp (this);
//	window->Show();
//	SetTopWindow (window);
//	SetExitOnFrameDelete (true);

	gnustepLoopTimer.SetOwner (this);
	this->Connect (wxID_ANY, wxEVT_TIMER,
		wxTimerEventHandler(TrivaApp::runGNUstepLoop));
	gnustepLoopTimer.Start(5,wxTIMER_CONTINUOUS);

	if (argc == 2){
//		NSAutoreleasePool *poolread = [[NSAutoreleasePool alloc] init];
		TrivaPajeComponent *trivaPaje = [[TrivaPajeComponent alloc] init];
		id reader = [trivaPaje componentWithName: @"FileReader"];
		[reader setInputFilename: WXSTRINGtoNSSTRING(argv[1])];
		[trivaPaje setReaderWithName: @"FileReader"];
		NSLog (@"Tracefile (%@). Reading.... please wait\n", WXSTRINGtoNSSTRING(argv[1]));
		while ([trivaPaje hasMoreData]){
			[trivaPaje readNextChunk: nil];
		}
//		[poolread release];
		NSLog (@"End of reading - %@ to %@.",
			[trivaPaje startTime], [trivaPaje endTime]);
		[trivaPaje setSelectionStartTime: [trivaPaje startTime]
			endTime: [trivaPaje endTime]];
	}else{
		NSLog (@"Please, provide a .trace file");
		exit(1);
	}
	return true;
}

int TrivaApp::OnExit()
{
        return 0;
}

void TrivaApp::runGNUstepLoop (wxTimerEvent& event)
{
	[[NSRunLoop currentRunLoop] runUntilDate:
		[NSDate dateWithTimeIntervalSinceNow:0.001]];
}