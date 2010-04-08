///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __TimeIntervalWindowAuto__
#define __TimeIntervalWindowAuto__

#include <wx/string.h>
#include <wx/stattext.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/sizer.h>
#include <wx/statline.h>
#include <wx/slider.h>
#include <wx/tglbtn.h>
#include <wx/textctrl.h>
#include <wx/button.h>
#include <wx/frame.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class TimeIntervalWindowAuto
///////////////////////////////////////////////////////////////////////////////
class TimeIntervalWindowAuto : public wxFrame 
{
	private:
	
	protected:
		wxStaticText* m_staticText1;
		wxStaticText* traceStartTime;
		wxStaticText* m_staticText3;
		wxStaticText* traceEndTime;
		
		wxStaticLine* m_staticline3;
		wxStaticText* m_staticText4;
		wxStaticText* timeSelectionStart;
		wxSlider* timeSelectionStartSlider;
		wxStaticLine* m_staticline4;
		wxStaticText* m_staticText5;
		wxStaticText* timeSelectionEnd;
		wxSlider* timeSelectionEndSlider;
		
		wxStaticText* m_staticText9;
		wxStaticText* m_staticText10;
		wxToggleButton* playButton;
		wxTextCtrl* m_textCtrl1;
		wxTextCtrl* m_textCtrl2;
		wxStaticLine* m_staticline11;
		wxButton* m_button1;
		
		// Virtual event handlers, overide them in your derived class
		virtual void startScroll( wxScrollEvent& event ){ event.Skip(); }
		virtual void endScroll( wxScrollEvent& event ){ event.Skip(); }
		virtual void play( wxCommandEvent& event ){ event.Skip(); }
		virtual void timeStep( wxCommandEvent& event ){ event.Skip(); }
		virtual void apply( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		TimeIntervalWindowAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva - Time Interval"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 300,400 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~TimeIntervalWindowAuto();
	
};

#endif //__TimeIntervalWindowAuto__
