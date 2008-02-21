#ifndef __PROTOCONTROLLER_H
#define __PROTOCONTROLLER_H

#ifndef TRIVAWXWIDGETS

#include <Foundation/Foundation.h>
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

	NSString *syncfile;
	NSArray *tracefile;
}
- (void) start;
- (id) initWithArgc: (int) argc andArgv: (char **) argv;

//HACK (workaround to receive trace file names as parameters, instead of using
//a GUI that does not exist)
- (void) setSyncfile: (NSString *) f;
- (void) setTracefile: (NSArray *) a;
- (NSString *) syncfile;
- (NSArray *) tracefile;

/* Commands: just to see (initialized|notinitialized) */
- (BOOL) startSession;
- (BOOL) endSession;
//- (void) applicationWillFinishLaunching: (NSNotification *)not;
@end


#else // TRIVAWXWIDGETS

#include <Foundation/Foundation.h>
//#include "reader/ProtoReader.h"
//#include "ogre-simulator/OgreProtoSimulator.h"

@class ProtoReader;
@class OgreProtoSimulator;
@class ProtoView;

#include <wx/wxprec.h>
#include <wx/wx.h>
#include "core/wxOgreRenderWindow.h"
#include "core/TrivaController.h"

class ProtoController : public wxApp
{
	private:
		ProtoReader *reader;
		OgreProtoSimulator *simulator;
		ProtoView *view;

		wxOgreRenderWindow *mOgre;
		Ogre::RenderWindow *mWindow;
		TrivaController *gui;
		NSAutoreleasePool *pool;
        
		BOOL sessionStarted;
	public:
		virtual bool OnInit();
		void changeState () { std::cout << "change State" << std::endl; };
};

class wxMyInput : public wxInputEventListener
{
	public:
		void onCharEvent(wxKeyEvent& evt);
		void onMouseEvent(wxMouseEvent& evt);
};

#endif // TRIVAWXWIDGETS

#endif
