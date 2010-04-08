///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __CommunicationPatternWindowAuto__
#define __CommunicationPatternWindowAuto__

class Triva3DFrame;

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
/// Class CommunicationPatternWindowAuto
///////////////////////////////////////////////////////////////////////////////
class CommunicationPatternWindowAuto : public wxFrame 
{
	private:
	
	protected:
		wxStatusBar* statusBar;
	
	public:
		Triva3DFrame* m3DFrame;
		CommunicationPatternWindowAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva - Communication Pattern"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,300 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~CommunicationPatternWindowAuto();
	
};

#endif //__CommunicationPatternWindowAuto__
