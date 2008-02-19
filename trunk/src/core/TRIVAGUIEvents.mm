#include "TRIVAGUIEvents.h"
#include <iostream>
#include <wx/wx.h>

TRIVAGUIEvents::TRIVAGUIEvents( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : TRIVAGUI (parent,id,title,pos,size,style)
{
}

void TRIVAGUIEvents::loadbundle( wxCommandEvent& event )
{
	wxDirDialog * openDirDialog = new wxDirDialog(this);
	openDirDialog->SetMessage (wxT("Choose a GNUstep Bundle Directory (*.bundle)"));
	if (openDirDialog->ShowModal() == wxID_OK){
		wxString fileName = openDirDialog->GetPath();
		std::cout << fileName.ToAscii() << std::endl;
	}
}

void TRIVAGUIEvents::exit( wxCommandEvent& event )
{
	Close(true);
}

void TRIVAGUIEvents::about( wxCommandEvent& event )
{
	TrivaAboutGui *win = new TrivaAboutGui (0, wxID_ANY);
	win->Show();
}
