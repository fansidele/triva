#include "TrivaController.h"

void TrivaController::scrollbarUpdate(float s, float e)
{
	//all values in microseconds (because scrollbar holds only int's, so we
	//need to get numbers at least greater than 1)
	int start = s * 1000000;
	int end = e * 1000000;
	int windowSize = 1000000;

	scrollbarRange = end - start;
	scrollbarPage = (float)scrollbarRange * .10;
	scrollbar->SetScrollbar (scrollbarPosition, windowSize,
		scrollbarRange, scrollbarPage, true);
}

void TrivaController::scrollbarEvent( wxScrollEvent& event )
{
	scrollbarPosition = event.GetPosition();\
	std::cout << scrollbarPosition << std::endl;
}
