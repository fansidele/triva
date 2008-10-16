#include "GUI_Preferences.h"

static float minp, maxp;

extern std::string WXSTRINGtoSTDSTRING (wxString wsa);
extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

void GUI_Preferences::startTimeSliderChanged( wxScrollEvent& event )
{
	/* check to see if window start time is greater than window end time */
	if (startTimeSlider->GetValue() > endTimeSlider->GetValue()){
		startTimeSlider->SetValue (endTimeSlider->GetValue());
	}else{
		float s = this->windowStartTime();
		statusBar->SetStatusText (NSSTRINGtoWXSTRING(
			[NSString stringWithFormat: @"start time: %f", s]));
	}
}
		
void GUI_Preferences::endTimeSliderChanged( wxScrollEvent& event )
{
	/* check to see if window end time is smaller than window start time */
	if (endTimeSlider->GetValue() < startTimeSlider->GetValue()){
		endTimeSlider->SetValue (startTimeSlider->GetValue());
	}else{
		float s = this->windowEndTime();
		statusBar->SetStatusText (NSSTRINGtoWXSTRING(
			[NSString stringWithFormat: @"end time: %f", s]));
	}
}

void GUI_Preferences::apply ( wxCommandEvent& event )
{
//	float t = atof(WXSTRINGtoSTDSTRING(m_textCtrl13->GetValue()).c_str());
//	controller->setTimeWindow (t);
	[controller->getView() hierarchyChanged];
}

void GUI_Preferences::close( wxCommandEvent& event )
{
	this->Hide();
}

GUI_Preferences::GUI_Preferences( wxWindow* parent, wxWindowID ide,
const wxString& title, const wxPoint& pos, const wxSize& size,
long style ) :
AutoGUI_Preferences ( parent, ide,
title, pos, size,
style )
{
}

void GUI_Preferences::onClose( wxCloseEvent& event )
{
        if (!event.CanVeto()){
                Close();
        }else{
                Hide();
        }
}

void GUI_Preferences::setMinMaxTime (float min, float max)
{
	minp = min;
	maxp = max;

	totalTimeText->SetValue (NSSTRINGtoWXSTRING(
		[NSString stringWithFormat: @"%f", max]));
}

float GUI_Preferences::windowStartTime ()
{
	float ret = (float)(maxp*(float)startTimeSlider->GetValue()/100);
	return ret;
}

float GUI_Preferences::windowEndTime ()
{
	float ret = (float)(maxp*(float)endTimeSlider->GetValue()/100);
	return ret;
}

