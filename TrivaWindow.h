#ifndef __TrivaWindow__
#define __TrivaWindow__

#include "TrivaWindowAuto.h"
#include <wx/app.h>

class TrivaWindow : public TrivaWindowAuto
{
public:
	wxApp *app;
	TrivaWindow( wxWindow* parent );
	void setTrivaApp (wxApp *a) { app = a; };
private:
	void squarifiedTreemap2D( wxCommandEvent& event );
	void appCommunication3D( wxCommandEvent& event );
	void resourceComm3D( wxCommandEvent& event );
	void squarifiedTreemap3D( wxCommandEvent& event );
	void memAccess2D( wxCommandEvent& event );
	void simgrid( wxCommandEvent& event );
	void exit( wxCommandEvent& event );
};

#endif //__TrivaWindowAuto__
