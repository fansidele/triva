#ifndef __GUI_BASE_H__
#define __GUI_BASE_H__

#include "TrivaAutoGeneratedGUI.h"
#include "gui/TrivaController.h"
/*
#include <wx/wxprec.h>
#include <wx/wx.h>
#include "reader/TrivaPajeReader.h"
#include <vector>
*/

class TrivaController;

class GUI_Base : public AutoGUI_Base
{
private:
	TrivaController *controller;

protected:
	void load( wxCommandEvent& event );
	void apply( wxCommandEvent& event );
	void close( wxCommandEvent& event );
	void onClose (wxCloseEvent& event );

public:
	void setController (TrivaController *t) { controller = t; };
	GUI_Base( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Visualization Base"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 380,250 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );

};

#endif 
