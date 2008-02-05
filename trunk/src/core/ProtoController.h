#ifndef __PROTOCONTROLLER_H
#define __PROTOCONTROLLER_H
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "reader/ProtoReader.h"
#include "ogre-simulator/OgreProtoSimulator.h"
#include "memory/ProtoMemory.h"
#include "view/ProtoView.h"

@interface ProtoController : NSObject
{
	ProtoReader *reader;
	OgreProtoSimulator *simulator;
	ProtoMemory *memory;
	ProtoView *view;

	BOOL sessionStarted;
	BOOL quit;
}
- (void) start;
- (id) initWithArgc: (int) argc andArgv: (char **) argv;

/* Commands: originated in the view component */
- (BOOL) startSession: (NSDictionary *) description;
- (BOOL) endSession;
//- (void) applicationWillFinishLaunching: (NSNotification *)not;
@end

#endif
