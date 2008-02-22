#ifndef __TrivaController__
#define __TrivaController__

#include <vector>
#include "TRIVAGUI.h"
#include "core/wxOgreRenderWindow.h"
#include <wx/wxprec.h>
#include <wx/wx.h>
#include "core/BundleGUIEvents.h"
#include "reader/ProtoReader.h"
#include "ogre-simulator/OgreProtoSimulator.h"
#include "view/ProtoView.h"
#include <Ogre.h>

class BundleGUIEvents;

enum TrivaApplicationState {Initialized,Configured,Running,Paused};


class TrivaController : public TRIVAGUI
{
private:
	ProtoView *view;
	OgreProtoSimulator *simulator;
	ProtoReader *reader;
	Ogre::RenderWindow *mWindow;
	std::vector<BundleGUIEvents*> bundlesGUI;

protected:
	// Handlers for TRIVAGUI events.
	void loadBundle( wxCommandEvent& event );
	void exit( wxCommandEvent& event );
	void about( wxCommandEvent& event );
	void bundlesView ( wxCommandEvent& event );
	void playClicked( wxCommandEvent& event );
	void pauseClicked( wxCommandEvent& event );
	void caputz( wxCommandEvent& event );
	
public:
	/** Constructor */
	void oneBundleConfigured();
	void _activateOgre();
	void _initOgre();
	TrivaController( wxWindow* parent );
	TrivaController( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("TRIVA"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 600,480 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );


/* States Category */
private:
	TrivaApplicationState applicationState;
	void applicationIsInitialized();
	void applicationIsConfigured();
	void applicationIsRunning();
	void applicationIsPaused();
public:
	void setState (TrivaApplicationState newState);
	TrivaApplicationState currentState();

/* Periodic timers */
private:
	wxTimer readTimer;

protected:
	void checkRead (wxTimerEvent& event);
};




#endif // __TrivaController__
