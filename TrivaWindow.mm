#include "TrivaWindow.h"
#include <iostream>

TrivaWindow::TrivaWindow (wxWindow *parent)
:
TrivaWindowAuto (parent)
{
}

void TrivaWindow::squarifiedTreemap2D( wxCommandEvent& event ){ event.Skip(); }
void TrivaWindow::appCommunication3D( wxCommandEvent& event ){ event.Skip(); }
void TrivaWindow::resourceComm3D( wxCommandEvent& event ){ event.Skip(); }
void TrivaWindow::squarifiedTreemap3D( wxCommandEvent& event ){ event.Skip(); }
void TrivaWindow::memAccess2D( wxCommandEvent& event ){ event.Skip(); }
void TrivaWindow::simgrid( wxCommandEvent& event ){ event.Skip(); }
void TrivaWindow::exit( wxCommandEvent& event ) {event.Skip(); }
