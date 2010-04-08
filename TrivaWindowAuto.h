///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __TrivaWindowAuto__
#define __TrivaWindowAuto__

#include <wx/string.h>
#include <wx/tglbtn.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/statline.h>
#include <wx/button.h>
#include <wx/sizer.h>
#include <wx/frame.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class TrivaWindowAuto
///////////////////////////////////////////////////////////////////////////////
class TrivaWindowAuto : public wxFrame 
{
	private:
	
	protected:
		wxToggleButton* squarifiedTreemap2Db;
		wxToggleButton* appCommunication3Db;
		wxToggleButton* resourceComm3Db;
		wxToggleButton* squarifiedTreemap3Db;
		wxToggleButton* memAccess2Db;
		wxToggleButton* simgridb;
		wxStaticLine* m_staticline1;
		wxButton* exitb;
		
		// Virtual event handlers, overide them in your derived class
		virtual void squarifiedTreemap2D( wxCommandEvent& event ){ event.Skip(); }
		virtual void appCommunication3D( wxCommandEvent& event ){ event.Skip(); }
		virtual void resourceComm3D( wxCommandEvent& event ){ event.Skip(); }
		virtual void squarifiedTreemap3D( wxCommandEvent& event ){ event.Skip(); }
		virtual void memAccess2D( wxCommandEvent& event ){ event.Skip(); }
		virtual void simgrid( wxCommandEvent& event ){ event.Skip(); }
		virtual void exit( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		TrivaWindowAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva Visualization Control"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 342,314 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~TrivaWindowAuto();
	
};

#endif //__TrivaWindowAuto__
