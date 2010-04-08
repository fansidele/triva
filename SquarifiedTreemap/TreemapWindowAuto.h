///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __TreemapWindowAuto__
#define __TreemapWindowAuto__

class TreemapDraw;

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
/// Class TreemapWindowAuto
///////////////////////////////////////////////////////////////////////////////
class TreemapWindowAuto : public wxFrame 
{
	private:
	
	protected:
		TreemapDraw* treemapDraw;
		wxStatusBar* statusBar;
	
	public:
		TreemapWindowAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva - Treemap"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,300 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~TreemapWindowAuto();
	
};

#endif //__TreemapWindowAuto__
