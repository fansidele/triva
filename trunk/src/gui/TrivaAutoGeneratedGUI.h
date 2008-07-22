///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Apr 21 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __TrivaAutoGeneratedGUI__
#define __TrivaAutoGeneratedGUI__

class Triva3DFrame;

#include <wx/panel.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/string.h>
#include <wx/scrolbar.h>
#include <wx/sizer.h>
#include <wx/bitmap.h>
#include <wx/image.h>
#include <wx/icon.h>
#include <wx/menu.h>
#include <wx/button.h>
#include <wx/toolbar.h>
#include <wx/statusbr.h>
#include <wx/frame.h>
#include <wx/statbmp.h>
#include <wx/stattext.h>
#include <wx/listbox.h>
#include <wx/checklst.h>
#include <wx/choice.h>
#include <wx/textctrl.h>
#include <wx/notebook.h>
#include <wx/checkbox.h>
#include <wx/statline.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class AutoGUI_Triva
///////////////////////////////////////////////////////////////////////////////
class AutoGUI_Triva : public wxFrame 
{
	private:
	
	protected:
		wxScrollBar* scrollbar;
		wxMenuBar* m_menubar2;
		wxMenu* application;
		wxMenu* m_menu3;
		wxMenuItem* clabels;
		wxMenuItem* slabels;
		wxMenu* navigation;
		wxMenu* m_menu6;
		wxToolBar* toolbar;
		wxButton* playButton;
		wxButton* pauseButton;
		wxButton* ZoomInB;
		wxButton* zoomOutB;
		wxButton* colorButton;
		wxButton* mergeButton;
		wxStatusBar* statusBar;
		
		// Virtual event handlers, overide them in your derived class
		virtual void killFocus( wxFocusEvent& event ){ event.Skip(); }
		virtual void setFocus( wxFocusEvent& event ){ event.Skip(); }
		virtual void scrollbarEvent( wxScrollEvent& event ){ event.Skip(); }
		virtual void loadBundle( wxCommandEvent& event ){ event.Skip(); }
		virtual void exit( wxCommandEvent& event ){ event.Skip(); }
		virtual void containerLabels( wxCommandEvent& event ){ event.Skip(); }
		virtual void stateLabels( wxCommandEvent& event ){ event.Skip(); }
		virtual void guiBaseSelection( wxCommandEvent& event ){ event.Skip(); }
		virtual void guiPreferencesSelection( wxCommandEvent& event ){ event.Skip(); }
		virtual void cameraForward( wxCommandEvent& event ){ event.Skip(); }
		virtual void cameraBackward( wxCommandEvent& event ){ event.Skip(); }
		virtual void cameraLeft( wxCommandEvent& event ){ event.Skip(); }
		virtual void cameraRight( wxCommandEvent& event ){ event.Skip(); }
		virtual void cameraUp( wxCommandEvent& event ){ event.Skip(); }
		virtual void cameraDown( wxCommandEvent& event ){ event.Skip(); }
		virtual void about( wxCommandEvent& event ){ event.Skip(); }
		virtual void playClicked( wxCommandEvent& event ){ event.Skip(); }
		virtual void pauseClicked( wxCommandEvent& event ){ event.Skip(); }
		virtual void zoomIn( wxCommandEvent& event ){ event.Skip(); }
		virtual void zoomOut( wxCommandEvent& event ){ event.Skip(); }
		virtual void changeColor( wxCommandEvent& event ){ event.Skip(); }
		virtual void mergeSelected( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		Triva3DFrame* m3DFrame;
		AutoGUI_Triva( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("TRIVA"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 585,480 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~AutoGUI_Triva();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class AutoGUI_About
///////////////////////////////////////////////////////////////////////////////
class AutoGUI_About : public wxFrame 
{
	private:
	
	protected:
		wxStaticBitmap* m_bitmap3;
		wxStaticText* m_staticText1;
	
	public:
		AutoGUI_About( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("About..."), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 400,150 ), long style = wxDEFAULT_FRAME_STYLE|wxSYSTEM_MENU );
		~AutoGUI_About();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class BundleGUI
///////////////////////////////////////////////////////////////////////////////
class BundleGUI : public wxFrame 
{
	private:
	
	protected:
		wxNotebook* m_notebook2;
		wxPanel* m_panel9;
		wxButton* selectTraceButton;
		wxStaticText* m_staticText5;
		wxListBox* traceFileOpened;
		wxButton* removeTraceFileButton;
		wxPanel* m_panel10;
		wxButton* selectSyncButton;
		wxStaticText* m_staticText51;
		wxListBox* syncFileOpened;
		wxButton* removeSyncFileButton;
		wxPanel* m_panel5;
		wxCheckListBox* setupCheckList;
		wxChoice* setupChoice;
		wxPanel* m_panel11;
		wxTextCtrl* statusText;
		
		
		wxButton* activateButton;
		
		// Virtual event handlers, overide them in your derived class
		virtual void traceFilePicker( wxCommandEvent& event ){ event.Skip(); }
		virtual void removeTraceFile( wxCommandEvent& event ){ event.Skip(); }
		virtual void syncFilePicker( wxCommandEvent& event ){ event.Skip(); }
		virtual void removeSyncFile( wxCommandEvent& event ){ event.Skip(); }
		virtual void activate( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		BundleGUI( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxEmptyString, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,361 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~BundleGUI();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class AutoGUI_Base
///////////////////////////////////////////////////////////////////////////////
class AutoGUI_Base : public wxFrame 
{
	private:
	
	protected:
		wxPanel* m_panel11;
		wxNotebook* base_type;
		wxPanel* m_panel7;
		wxStaticText* m_staticText7;
		wxButton* configuration_file;
		wxStaticText* m_staticText8;
		wxTextCtrl* width;
		wxStaticText* m_staticText9;
		wxTextCtrl* height;
		wxStaticText* m_staticText20;
		wxCheckBox* m_checkBox1;
		wxPanel* m_panel8;
		wxStaticText* m_staticText21;
		wxPanel* m_panel10;
		wxStaticText* m_staticText71;
		wxButton* rg_configuration_file;
		wxStaticText* m_staticText18;
		wxChoice* rg_choice;
		wxStaticLine* m_staticline3;
		wxButton* m_button17;
		wxButton* m_button18;
		wxStatusBar* status;
		
		// Virtual event handlers, overide them in your derived class
		virtual void onClose( wxCloseEvent& event ){ event.Skip(); }
		virtual void load( wxCommandEvent& event ){ event.Skip(); }
		virtual void rg_load_graph( wxCommandEvent& event ){ event.Skip(); }
		virtual void apply( wxCommandEvent& event ){ event.Skip(); }
		virtual void close( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		AutoGUI_Base( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Visualization Base Configuration"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 650,300 ), long style = wxCAPTION|wxTAB_TRAVERSAL );
		~AutoGUI_Base();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class AutoGUI_Preferences
///////////////////////////////////////////////////////////////////////////////
class AutoGUI_Preferences : public wxFrame 
{
	private:
	
	protected:
		wxPanel* m_panel13;
		wxStaticText* m_staticText7;
		wxTextCtrl* m_textCtrl13;
		wxStaticLine* m_staticline3;
		wxButton* m_button17;
		wxButton* m_button18;
		
		// Virtual event handlers, overide them in your derived class
		virtual void onClose( wxCloseEvent& event ){ event.Skip(); }
		virtual void apply( wxCommandEvent& event ){ event.Skip(); }
		virtual void close( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		AutoGUI_Preferences( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva Preferences"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 252,210 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~AutoGUI_Preferences();
	
};

#endif //__TrivaAutoGeneratedGUI__
