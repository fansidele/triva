#ifndef __TrivaController__
#define __TrivaController__

#include <vector>
#include "TrivaAutoGeneratedGUI.h"
#include "gui/Triva3DFrame.h"
#include <wx/wxprec.h>
#include <wx/wx.h>
#include "gui/BundleGUIEvents.h"
#include "draw/ProtoView.h"
#include "fusion/TrivaFusion.h"
#include "gui/camera/CameraManager.h"
#include "draw/ambient/AmbientManager.h"
#include <Ogre.h>

#include "paje-simulator/TrivaPajeComponent.h"
#include "reader/TrivaPajeReader.h"

#include "gui/GUI_Base.h"

class TrivaColorWindowEvents;
class BundleGUIEvents;
class GUI_Base;

enum TrivaApplicationState {Initialized,Configured,Running,Paused};


class TrivaController : public TrivaAutoGeneratedGUI
{
private:
	ProtoView *view;
	TrivaFusion *fusion;
	TrivaPajeReader *reader;
	TrivaPajeComponent *trivaPaje;
	Ogre::RenderWindow *mWindow;
	std::vector<BundleGUIEvents*> bundlesGUI;

	GUI_Base *guiBaseWindow;
protected:
	void guiBaseSelection( wxCommandEvent& event );

protected:
	// Handlers for TRIVAGUI events.
	void loadBundle( wxCommandEvent& event );
	void exit( wxCommandEvent& event );
	void about( wxCommandEvent& event );
	void bundlesView ( wxCommandEvent& event );
	void playClicked( wxCommandEvent& event );
	void pauseClicked( wxCommandEvent& event );
	void cameraCheckbox ( wxCommandEvent& event );
	void changeColor( wxCommandEvent& event );
	void mergeSelected (wxCommandEvent& event);

	
public:
	ProtoView *getView () { return view; };

	/** Constructor */
	void oneBundleConfigured();
	TrivaController( wxWindow* parent );
	TrivaController( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("TRIVA"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 600,480 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
	~TrivaController ();

/* Zoom Category */
protected:
	double xScale, yScale, zScale;
	void configureZoom ();
	void zoomIn ( wxCommandEvent& event );	
	void zoomOut ( wxCommandEvent& event );	

/* Select category */
private:
	PajeEntity *selectedEntity;
	Ogre::MovableObject *selectedObject;
	std::vector<Ogre::MovableObject*> containersSelected;

private:
	void unselectSelected ();
	void selectContainer (Ogre::MovableObject *objectToSelect);
	void selectState (Ogre::MovableObject
*objectToSelect, Ogre::Vector3 hitAt);
	void selectLink (Ogre::MovableObject
*objectToSelect, Ogre::Vector3 hitAt);

public:
	void selectObjectIdentifier (Ogre::MovableObject *objectToSelect, Ogre::Vector3 hitAt);
	wxColour convertOgreColor (Ogre::ColourValue v);
	Ogre::ColourValue convertWxColor (wxColor c);


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

protected:
	void checkRead (wxTimerEvent& event);

/* from old ProtoView */
private:
	CameraManager *cameraManager;
	AmbientManager *ambientManager;

/* camera category */
protected:
	void cameraForward( wxCommandEvent& event );
	void cameraBackward( wxCommandEvent& event );
	void cameraLeft( wxCommandEvent& event );
	void cameraRight( wxCommandEvent& event );
	void cameraUp( wxCommandEvent& event );
	void cameraDown( wxCommandEvent& event );

/* base category */
protected:
	void squarifiedTreemap( wxCommandEvent& event );
	void originalTreemap( wxCommandEvent& event );
	void resourcesGraph( wxCommandEvent& event );
	void applicationGraph( wxCommandEvent& event );
	void initializeBaseCategory ();
};

#endif // __TrivaController__
