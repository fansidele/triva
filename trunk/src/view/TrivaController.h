#ifndef __TrivaController__
#define __TrivaController__

#include <vector>
#include "TrivaAutoGeneratedGUI.h"
#include "view/Triva3DFrame.h"
#include <wx/wxprec.h>
#include <wx/wx.h>
#include "view/BundleGUIEvents.h"
/*
#include "reader/ProtoReader.h"
#include "ogre-simulator/OgreProtoSimulator.h"
#include "view/ProtoView.h"
*/
#include "view/camera/CameraManager.h"
#include "view/ambient/AmbientManager.h"
#include "view/selector/SelectorManager.h"
#include <Ogre.h>

#include "paje-simulator/TrivaPajeComponent.h"

class BundleGUIEvents;
class SelectorManager;

enum TrivaApplicationState {Initialized,Configured,Running,Paused};


class TrivaController : public TrivaAutoGeneratedGUI
{
private:
/*
	ProtoView *view;
	OgreProtoSimulator *simulator;
	ProtoReader *reader;
*/
	TrivaPajeComponent *trivaPaje;
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
	void cameraCheckbox ( wxCommandEvent& event );
	
public:
	/** Constructor */
	void oneBundleConfigured();
	TrivaController( wxWindow* parent );
	TrivaController( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("TRIVA"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 600,480 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
	~TrivaController ();
	void disableInputMouseFocus ();
	void enableInputMouseFocus ();

/* Zoom Category */
protected:
	double xScale, yScale, zScale;
	void configureZoom ();
	void zoomIn ( wxCommandEvent& event );	
	void zoomOut ( wxCommandEvent& event );	

/* Select category */
public:
	void selectObjectIdentifier (std::string name);
	void unselectObjectIdentifier (std::string name);

/* Draw category */
protected:
	void configureDraw ();
	void containerLabels ( wxCommandEvent& event );	
	void stateLabels ( wxCommandEvent& event );	



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
	wxTimer nsRunloopTimer;

protected:
	void checkRead (wxTimerEvent& event);
	void runGNUstepLoop (wxTimerEvent& event);

/* from old ProtoView */
private:
	CameraManager *cameraManager;
	AmbientManager *ambientManager;
	SelectorManager *selectorManager;
};

#endif // __TrivaController__
