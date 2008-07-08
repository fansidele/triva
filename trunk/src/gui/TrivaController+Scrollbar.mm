#include "TrivaController.h"

void TrivaController::scrollbarUpdate(float start, float end)
{
	scrollbarRange = end - start;
	scrollbarPage = (float)scrollbarRange * .10;
	this->adjustScrollbar();
}

#define SCROLLBAR_T 100

void TrivaController::cameraMoved ()
{
	scrollbarPosition = cameraManager->getYPosition();
	adjustScrollbar();
}

void TrivaController::scrollbarEvent( wxScrollEvent& event )
{
	scrollbarPosition = event.GetPosition();
	cameraManager->moveCameraToY (scrollbarPosition/SCROLLBAR_T);
}

void TrivaController::adjustScrollbar()
{
	float windowSize = 1000;
	int pos = scrollbarPosition*SCROLLBAR_T;
	int thumbsize = windowSize*SCROLLBAR_T;
	int range = scrollbarRange*SCROLLBAR_T;
	int page = scrollbarPage*SCROLLBAR_T;
	scrollbar->SetScrollbar (pos, thumbsize, range, page);

}

#undef MICROSECONDS
