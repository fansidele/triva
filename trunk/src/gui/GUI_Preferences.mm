#include "GUI_Preferences.h"

extern std::string WXSTRINGtoSTDSTRING (wxString wsa);
extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

void GUI_Preferences::apply ( wxCommandEvent& event )
{
	float t = atof(WXSTRINGtoSTDSTRING(m_textCtrl13->GetValue()).c_str());
	controller->setTimeWindow (t);
}

void GUI_Preferences::close( wxCommandEvent& event )
{
	this->Hide();
}

GUI_Preferences::GUI_Preferences( wxWindow* parent, wxWindowID ide,
const wxString& title, const wxPoint& pos, const wxSize& size,
long style ) :
AutoGUI_Preferences ( parent, ide,
title, pos, size,
style )
{
}
