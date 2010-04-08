#include "TimeIntervalWindow.h"
#include <iostream>

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

TimeIntervalWindow::TimeIntervalWindow( wxWindow* parent )
:
TimeIntervalWindowAuto( parent )
{

}

void TimeIntervalWindow::setTraceStartTime (wxString str)
{
	traceStartTime->SetLabel (str);
}

void TimeIntervalWindow::setTraceEndTime (wxString str)
{
	traceEndTime->SetLabel (str);
}

void TimeIntervalWindow::setSelectionStartTime (wxString str)
{
	timeSelectionStart->SetLabel (str);
}

void TimeIntervalWindow::setSelectionEndTime (wxString str)
{
	timeSelectionEnd->SetLabel (str);
}

void TimeIntervalWindow::updateText ()
{
	this->setSelectionStartTime(
		NSSTRINGtoWXSTRING([NSString stringWithFormat: @"%f", 
			[filter traceTimeForSliderPosition: timeSelectionStartSlider->GetValue()]]));
	this->setSelectionEndTime(
		NSSTRINGtoWXSTRING([NSString stringWithFormat: @"%f", 
			[filter traceTimeForSliderPosition: timeSelectionEndSlider->GetValue()]]));
}

void TimeIntervalWindow::setSlidersRange (int start, int end)
{
	timeSelectionStartSlider->SetRange (start, end);
	timeSelectionEndSlider->SetRange (start, end);
	timeSelectionStartSlider->SetValue(start);
	timeSelectionEndSlider->SetValue(end);
	this->updateText ();
}

void TimeIntervalWindow::setSlidersValue (int start, int end)
{
	timeSelectionStartSlider->SetValue (start);
	timeSelectionEndSlider->SetValue (end);
	this->updateText();
}

/* callbacks */
void TimeIntervalWindow::startScroll( wxScrollEvent& event )
{
	if (timeSelectionStartSlider->GetValue() > 
		timeSelectionEndSlider->GetValue()){
		timeSelectionStartSlider->SetValue
			(timeSelectionEndSlider->GetValue());
	}
	this->updateText();
}
void TimeIntervalWindow::endScroll( wxScrollEvent& event )
{
	if (timeSelectionEndSlider->GetValue() <
		timeSelectionStartSlider->GetValue()){
		timeSelectionEndSlider->SetValue
			(timeSelectionStartSlider->GetValue());
	}
	this->updateText();
}
void TimeIntervalWindow::apply( wxCommandEvent& event )
{
	[filter setTimeIntervalFrom: 
			timeSelectionStartSlider->GetValue()
				 to:
			timeSelectionEndSlider->GetValue()];
}

void TimeIntervalWindow::play( wxCommandEvent& event )
{
	wxString forwardInSec =  m_textCtrl1->GetValue();
	double freq;
	freq = [WXSTRINGtoNSSTRING(m_textCtrl1->GetValue()) doubleValue]*1000;
	timeStep = [WXSTRINGtoNSSTRING (forwardInSec) doubleValue];
	static bool clicked = false;
	if (!clicked){
		playTimer.SetOwner (this);
		playTimer.Start (timeStep, wxTIMER_CONTINUOUS);
		this->Connect (wxID_ANY,
			wxEVT_TIMER,
			wxTimerEventHandler(TimeIntervalWindow::forwardTime));
		clicked = true;
	}else{
		playTimer.Stop();
		clicked = false;
	}
}

void TimeIntervalWindow::forwardTime( wxTimerEvent& event)
{
	if ([filter forwardSelectionTime: timeStep]){
		playButton->SetValue(false);
		wxCommandEvent ev;
		this->play (ev);
	}
}
