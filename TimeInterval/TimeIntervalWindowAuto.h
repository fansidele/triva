///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __TimeIntervalWindowAuto__
#define __TimeIntervalWindowAuto__

class SliceDraw;

#include <wx/string.h>
#include <wx/stattext.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/sizer.h>
#include <wx/statline.h>
#include <wx/checkbox.h>
#include <wx/slider.h>
#include <wx/textctrl.h>
#include <wx/button.h>
#include <wx/panel.h>
#include <wx/frame.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class TimeIntervalWindowAuto
///////////////////////////////////////////////////////////////////////////////
class TimeIntervalWindowAuto : public wxFrame 
{
	private:
	
	protected:
		wxStaticText* m_staticText73;
		wxStaticLine* m_staticline11;
		wxStaticText* m_staticText4;
		wxStaticText* m_staticText83;
		wxButton* m_button4;
		wxStaticLine* m_staticline15;
		wxStaticText* m_staticText84;
		wxStaticText* m_staticText85;
		wxStaticText* m_staticText87;
		wxButton* playButton;
		wxButton* pauseButton;
		
		// Virtual event handlers, overide them in your derived class
		virtual void sliderChanged( wxScrollEvent& event ){ event.Skip(); }
		virtual void preciseSliceEntered( wxCommandEvent& event ){ event.Skip(); }
		virtual void apply( wxCommandEvent& event ){ event.Skip(); }
		virtual void animationSliderChanged( wxScrollEvent& event ){ event.Skip(); }
		virtual void play( wxCommandEvent& event ){ event.Skip(); }
		virtual void pause( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		wxStaticText* traceStartTime;
		wxStaticText* traceEndTime;
		wxCheckBox* timeSliceCheckBox;
		wxSlider* startSlider;
		wxSlider* sizeSlider;
		wxTextCtrl* timeSelectionStart;
		wxTextCtrl* timeSelectionEnd;
		SliceDraw* sliceDraw;
		wxSlider* forwardSlider;
		wxStaticText* forward;
		wxSlider* frequencySlider;
		wxStaticText* frequency;
		TimeIntervalWindowAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva - Time Interval"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 288,443 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~TimeIntervalWindowAuto();
	
};

#endif //__TimeIntervalWindowAuto__
