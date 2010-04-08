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

/* callbacks */
void TimeIntervalWindow::sliderChanged( wxScrollEvent& event )
{
	[filter sliderChanged];
}

void TimeIntervalWindow::animationSliderChanged( wxScrollEvent& event )
{
	[filter animationSliderChanged];
}

void TimeIntervalWindow::preciseSliceEntered( wxCommandEvent& event )
{
	[filter preciseSliceEntered];
}

void TimeIntervalWindow::apply( wxCommandEvent& event )
{
	[filter apply];
}

void TimeIntervalWindow::play( wxCommandEvent& event )
{
	[filter play];
}

void TimeIntervalWindow::pause( wxCommandEvent& event )
{
	[filter pause];
}

void TimeIntervalWindow::animate( wxTimerEvent& event)
{
	[filter animate];
}
