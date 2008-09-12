#include "GUI_CombinedCounter.h"

extern std::string WXSTRINGtoSTDSTRING (wxString wsa);
extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

void GUI_CombinedCounter::addStateType ( wxCommandEvent& event )
{
}

void GUI_CombinedCounter::apply ( wxCommandEvent& event )
{
}

void GUI_CombinedCounter::close( wxCommandEvent& event )
{
	this->Hide();
}

GUI_CombinedCounter::GUI_CombinedCounter( wxWindow* parent, wxWindowID ide,
const wxString& title, const wxPoint& pos, const wxSize& size,
long style ) :
AutoGUI_CombinedCounter ( parent, ide,
title, pos, size,
style )
{
	TrivaController *c = (TrivaController *)parent;
	ProtoView *view = c->getView();
}

void GUI_CombinedCounter::onClose( wxCloseEvent& event )
{
	if (!event.CanVeto()){
		Close();
	}else{
		Hide();
	}
}
