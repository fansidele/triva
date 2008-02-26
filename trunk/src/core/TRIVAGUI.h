///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Feb 21 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __TRIVAGUI__
#define __TRIVAGUI__

class wxOgreRenderWindow;

#include <wx/panel.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/string.h>
#include <wx/sizer.h>
#include <wx/bitmap.h>
#include <wx/image.h>
#include <wx/menu.h>
#include <wx/button.h>
#include <wx/checkbox.h>
#include <wx/toolbar.h>
#include <wx/frame.h>
#include <wx/statbmp.h>
#include <wx/stattext.h>
#include <wx/listbox.h>
#include <wx/textctrl.h>
#include <wx/notebook.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class TRIVAGUI
///////////////////////////////////////////////////////////////////////////////
class TRIVAGUI : public wxFrame 
{
	private:
	
	protected:
		wxOgreRenderWindow* mOgre;
		wxMenuBar* m_menubar2;
		wxMenu* application;
		wxMenu* m_menu6;
		wxToolBar* toolbar;
		wxButton* playButton;
		wxButton* pauseButton;
		wxCheckBox* camCheckbox;
		
		// Virtual event handlers, overide them in your derived class
		virtual void loadBundle( wxCommandEvent& event ){ event.Skip(); }
		virtual void exit( wxCommandEvent& event ){ event.Skip(); }
		virtual void about( wxCommandEvent& event ){ event.Skip(); }
		virtual void playClicked( wxCommandEvent& event ){ event.Skip(); }
		virtual void pauseClicked( wxCommandEvent& event ){ event.Skip(); }
		virtual void cameraCheckbox( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		TRIVAGUI( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("TRIVA"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 600,480 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~TRIVAGUI();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class TrivaAboutGui
///////////////////////////////////////////////////////////////////////////////
class TrivaAboutGui : public wxFrame 
{
	private:
	
	protected:
		wxStaticBitmap* m_bitmap3;
		wxStaticText* m_staticText1;
	
	public:
		TrivaAboutGui( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("About..."), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 400,150 ), long style = wxDEFAULT_FRAME_STYLE|wxSYSTEM_MENU );
		~TrivaAboutGui();
	
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

#endif //__TRIVAGUI__