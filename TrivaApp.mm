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
	pool = [[NSAutoreleasePool alloc] init];

//	TrivaWindow *window = new TrivaWindow ((wxWindow*)NULL);
//	window->setTrivaApp (this);
//	window->Show();
//	SetTopWindow (window);
//	SetExitOnFrameDelete (true);

#ifdef HAVE_HCMREADER
	TrivaPajeComponent *trivaPaje = [[TrivaPajeComponent alloc] init];
	id reader = [trivaPaje componentWithName: @"HCMReader"];
        /* 3 - thread to wait data from hcm and then send to paje */
        [NSThread
                detachNewThreadSelector: @selector (waitForDataFromHCM:)
                toTarget:reader
                withObject: nil];

        /* simulator HCM producer */
        [NSThread
                detachNewThreadSelector: @selector (producer:)
                toTarget:reader
                withObject: nil];
#endif

	gnustepLoopTimer.SetOwner (this);
	this->Connect (wxID_ANY, wxEVT_TIMER,
		wxTimerEventHandler(TrivaApp::runGNUstepLoop));
	gnustepLoopTimer.Start(5,wxTIMER_CONTINUOUS);

#ifndef HAVE_HCMREADER
	if (argc > 1){
//		NSAutoreleasePool *poolread = [[NSAutoreleasePool alloc] init];
		TrivaPajeComponent *trivaPaje = [[TrivaPajeComponent alloc] init];
		int i;
		for (i = 0; i < argc; i++){	
			[trivaPaje addParameter: WXSTRINGtoNSSTRING(argv[i])];
		}
		[trivaPaje createComponentGraph]; /*must be called after param*/
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
#endif
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
