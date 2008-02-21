#include "TrivaController.h"

wxString NSSTRINGtoWXSTRING (NSString *ns)
{
	if (ns == nil){
		return wxString();
	}
	return wxString::FromAscii ([ns cString]);
}

TrivaController::TrivaController( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : TRIVAGUI (parent,id,title,pos,size,style)
{
}


void TrivaController::exit( wxCommandEvent& event )
{
	Close(true);
}

void TrivaController::about( wxCommandEvent& event )
{
	TrivaAboutGui *win = new TrivaAboutGui (0, wxID_ANY);
	win->Show();
}

void TrivaController::bundlesView ( wxCommandEvent& event )
{
//	bundlesAppear->Check (!bundlesAppear->IsChecked());
//	std::vector<wxWindow*>::iterator it;
//	for (it = bundlesGUI.begin(); it != bundlesGUI.end(); it++){
//		if (bundlesAppear->IsChecked()){
//			it->Show();
//		}else{
//			it->Hide();
//		}
//	}
	
}

void TrivaController::loadbundle ( wxCommandEvent& event )
{
/*
	wxDirDialog * openDirDialog = new wxDirDialog(this);
	openDirDialog->SetMessage (wxT("Choose a GNUstep Bundle Directory (*.bundle)"));
	if (openDirDialog->ShowModal() == wxID_OK){
		wxString fileName = openDirDialog->GetPath();
	}
*/
	if (![reader loadDIMVisualBundle: @"dimvisual-kaapi.bundle"]){
		 wxMessageDialog *dial = new wxMessageDialog(NULL, 
    wxT("Error loading bundle (more messages in the console)"), wxT("Error"), wxOK | wxICON_ERROR);
 dial->ShowModal();
	}else{
		BundleGUIEvents *ev = new BundleGUIEvents(this);
		ev->setBundleName ("dimvisual-kaapi.bundle");
		ev->setReader (reader);
		if (bundlesAppear->IsChecked()){
			ev->Show();
		}
		bundlesGUI.push_back(ev);
	}

}

void TrivaController::playClicked( wxCommandEvent& event )
{
	if (event.IsChecked()){
//		controller->changeState();
		wxCommandEvent event( wxEVT_MY_EVENT, GetId() );
		event.SetEventObject( this );
		GetEventHandler()->ProcessEvent( event );
	}else{
//		controller->changeState();
	}
}

DEFINE_EVENT_TYPE(wxEVT_MY_EVENT)


BEGIN_EVENT_TABLE(TrivaController, wxFrame)
	EVT_COMMAND  (wxID_ANY, wxEVT_MY_EVENT, TrivaController::OnProcessCustom)
END_EVENT_TABLE()

