///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Feb 12 2008)
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
#include <wx/statusbr.h>
#include <wx/bitmap.h>
#include <wx/image.h>
#include <wx/menu.h>
#include <wx/toolbar.h>
#include <wx/frame.h>
#include <wx/statbmp.h>
#include <wx/stattext.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class TRIVAGUI
///////////////////////////////////////////////////////////////////////////////
class TRIVAGUI : public wxFrame 
{
	private:
	
	protected:
		wxStatusBar* m_statusBar1;
		wxMenuBar* m_menubar1;
		wxMenu* application;
		wxMenu* help;
		wxToolBar* m_toolBar1;
		
		// Virtual event handlers, overide them in your derived class
		virtual void loadbundle( wxCommandEvent& event ){ event.Skip(); }
		virtual void exit( wxCommandEvent& event ){ event.Skip(); }
		virtual void about( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		wxOgreRenderWindow* mOgre;
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

#endif //__TRIVAGUI__
