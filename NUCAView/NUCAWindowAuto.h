///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __NUCAWindowAuto__
#define __NUCAWindowAuto__

class NUCADraw;

#include <wx/panel.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/string.h>
#include <wx/sizer.h>
#include <wx/statusbr.h>
#include <wx/frame.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class NUCAWindowAuto
///////////////////////////////////////////////////////////////////////////////
class NUCAWindowAuto : public wxFrame 
{
	private:
	
	protected:
		NUCADraw* draw;
		wxStatusBar* statusBar;
	
	public:
		NUCAWindowAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva - NUCA"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,300 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~NUCAWindowAuto();
	
};

#endif //__NUCAWindowAuto__