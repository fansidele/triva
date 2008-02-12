#include "ProtoController.h"

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

	[self startSession: nil];
	
	quit = NO;
	sessionStarted = NO;
	return self;
}

- (void) start
{
	while (!quit){
		quit = [view refresh];

		if (sessionStarted){
			if (![view paused]){
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
	[super dealloc];
}

- (BOOL) startSession: (NSDictionary *) description
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
@end
