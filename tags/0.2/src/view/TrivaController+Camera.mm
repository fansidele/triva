#include "TrivaController.h"

void TrivaController::cameraForward( wxCommandEvent& event )
{
	cameraManager->cameraForward();
}

void TrivaController::cameraBackward( wxCommandEvent& event )
{
	cameraManager->cameraBackward();
}

void TrivaController::cameraLeft( wxCommandEvent& event )
{
	cameraManager->cameraLeft();
}

void TrivaController::cameraRight( wxCommandEvent& event )
{
	cameraManager->cameraRight();
}

void TrivaController::cameraUp( wxCommandEvent& event )
{
	cameraManager->cameraUp();
}

void TrivaController::cameraDown( wxCommandEvent& event )
{
	cameraManager->cameraDown();
}


