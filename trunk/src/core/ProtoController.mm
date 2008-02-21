#include "ProtoController.h"

#ifndef TRIVAWXWIDGETS

@implementation ProtoController
- (id) initWithArgc: (int) argc andArgv: (char **) argv
{
	self = [super init];

/*
	if (argc > 1){
		reader = [[ProtoReader alloc] initWithArgc: argc andArgv: argv];
		if (reader == nil){
			return nil;
		}
	}
*/

	view = [[ProtoView alloc] init];
	[view setController: self];

	[self startSession];
	
	quit = NO;
	sessionStarted = NO;
	return self;
}

- (void) start
{
	while (!quit){
		quit = [view refresh];

		if (sessionStarted){
			if (![view isPaused]){
				if ([reader hasMoreData]){
					[reader read];
				}
			}
		}
	}
	[view end];
}

- (void) dealloc
{
	NSLog (@"%s", __FUNCTION__);
	NSLog (@"%d", [reader retainCount]);
	[view release];
	[memory release];
	[simulator release];
	[reader release];

	[tracefile release];
	[syncfile release];
	[super dealloc];
}

- (BOOL) startSession
{
	/* destroy previous */
	[self endSession];

	/* create them */
	reader = [[ProtoReader alloc] init];
	simulator = [[OgreProtoSimulator alloc] init];

	/* connect them */
	[reader setOutput: simulator];
	[simulator setInput: reader];
	[simulator setOutput: view];
	[view setInput: simulator];

	NSLog (@"%s", __FUNCTION__);
	sessionStarted = YES;
	return true;
}

- (BOOL) endSession
{
	//[reader release]; for now, he is iniatilized just once
	[simulator release];
	[memory release];

	return true;
}

/*
- (void) applicationWillFinishLaunching: (NSNotification *)not
{
	NSLog (@"############################################");
	NSLog (@"%s", __FUNCTION__);
}

*/

- (void)applicationWillTerminate:(NSNotification *)notif
{
	NSLog (@"############################################");
	NSLog (@"%s", __FUNCTION__);
}

- (void) setSyncfile: (NSString *) f
{
	syncfile = f;
	[syncfile retain];
}

- (void) setTracefile: (NSArray *) a
{
	tracefile = a;
	[tracefile retain];
}

- (NSString *) syncfile
{
	return syncfile;
}

- (NSArray *) tracefile
{
	return tracefile;
}
@end

#else //TRIVAWXWIDGETS

IMPLEMENT_APP(ProtoController);

bool ProtoController::OnInit()
{
	pool = [[NSAutoreleasePool alloc] init];

	ProtoView *view = [[ProtoView alloc] init];
	[view step1];

	TRIVAGUIEvents *gui = new TRIVAGUIEvents (0, wxID_ANY);

	wxMyInput *inp = new wxMyInput ();

        wxOgreRenderWindow *mOgre = gui->mOgre;
        mOgre->createRenderWindow ();
	mOgre->addInputListener (inp);

        Ogre::RenderWindow *win = mOgre->getRenderWindow();
	[view createSceneManager];
	[view step4: win];

	/* create them */
	reader = [[ProtoReader alloc] init];
	simulator = [[OgreProtoSimulator alloc] init];

	/* connect them */
	[reader setOutput: simulator];
	[simulator setInput: reader];
	[simulator setOutput: view];
	[view setInput: simulator];

	gui->setReader (reader);
//	gui->setController (this);
	gui->Show();

	sessionStarted = true;
	return true;
}

void wxMyInput::onCharEvent(wxKeyEvent& evt)
{
//	std::cout << __FUNCTION__ << std::endl;
}

void wxMyInput::onMouseEvent(wxMouseEvent& evt)
{
//	std::cout << __FUNCTION__ << std::endl;
}

#endif //TRIVAWXWIDGETS
