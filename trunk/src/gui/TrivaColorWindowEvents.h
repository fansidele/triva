#ifndef __TrivaColorWindowEvents__
#define __TrivaColorWindowEvents__

#include "TrivaAutoGeneratedGUI.h"
#include "gui/TrivaController.h"
#include <wx/wxprec.h>
#include <wx/wx.h>
#include <vector>

class TrivaController;

class TrivaColorWindowEvents : public TrivaColorWindow
{
private:
	TrivaController *controller;

public:
	void setController (TrivaController *t) { controller = t; };
	void addMaterialOption (wxString materialName);
	/** Constructor */
	TrivaColorWindowEvents( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxEmptyString, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,300 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );

};

#endif // __TrivaColorWindowEvents__
