#include "TrivaController.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

#define SCROLLBAR_T 100

void TrivaController::setTimeWindow (float t)
{
	timeWindow = t;
	this->adjustScrollbar();
}

void TrivaController::scrollbarUpdate(float start, float end)
{
	scrollbarRange = (end - start);
	this->adjustScrollbar();
}

void TrivaController::cameraMoved ()
{
//	scrollbarPosition = cameraManager->getYPosition();
//	adjustScrollbar();
}

void TrivaController::scrollbarEvent( wxScrollEvent& event )
{
	scrollbarPosition = ((float)event.GetPosition())/(float)SCROLLBAR_T;
	cameraManager->moveCameraToY (scrollbarPosition);
}

void TrivaController::adjustScrollbar()
{
	int pos = scrollbarPosition*SCROLLBAR_T;
	int thumbsize = timeWindow*SCROLLBAR_T;
	int range = scrollbarRange*SCROLLBAR_T;
	int page = thumbsize;

	scrollbar->SetScrollbar (pos, thumbsize, range, page);
	statusBar->SetStatusText(NSSTRINGtoWXSTRING ([NSString stringWithFormat: @"Current Time: %f", scrollbarPosition]));

}

#undef MICROSECONDS
