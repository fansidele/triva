#include "TrivaController.h"

wxString NSSTRINGtoWXSTRING (NSString *ns)
{
	if (ns == nil){
		return wxString();
	}
	return wxString::FromAscii ([ns cString]);
}

void TrivaController::_activateOgre()
{
	std::cout << "##" << __FUNCTION__ << std::endl;
	ProtoView *view = [[ProtoView alloc] init];
	[view step1];

	std::cout << "#########################################"<< std::endl;
	//wxMyInput *inp = new wxMyInput ();	

	std::cout << mOgre << std::endl;
	mOgre->createRenderWindow ();
	std::cout << "#########################################"<< std::endl;
	//mOgre->addInputListener (inp);

	Ogre::RenderWindow *win = mOgre->getRenderWindow();
	[view createSceneManager];
	[view step4: win];
}

TrivaController::TrivaController( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : TRIVAGUI (parent,id,title,pos,size,style)
{
	reader = [[ProtoReader alloc] init];
	toolbar->Disable();
}


void TrivaController::caputz( wxCommandEvent& event )
{
	std::cout << "##" << __FUNCTION__ << std::endl;
}

void TrivaController::exit( wxCommandEvent& event )
{
	std::cout << "##" << __FUNCTION__ << std::endl;
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

void TrivaController::loadBundle ( wxCommandEvent& event )
{

	if (![reader loadDIMVisualBundle: @"dimvisual-kaapi.bundle"]){
		 wxMessageDialog *dial = new wxMessageDialog(NULL, 
    wxT("Error loading bundle (more messages in the console)"), wxT("Error"), wxOK | wxICON_ERROR);
 dial->ShowModal();
	}else{
		BundleGUIEvents *ev = new BundleGUIEvents(this);
		ev->setBundleName ("dimvisual-kaapi.bundle");
		ev->setController (this);
		ev->setReader (reader);
		ev->Show();
		bundlesGUI.push_back(ev);
	}

}


void TrivaController::playClicked( wxCommandEvent& event )
{
	std::cout << __FUNCTION__ << std::endl;
	if (event.IsChecked()){
//		controller->changeState();
//		wxCommandEvent event( wxEVT_MY_EVENT, GetId() );
//		event.SetEventObject( this );
//		GetEventHandler()->ProcessEvent( event );
	}else{
//		controller->changeState();
	}
}

void TrivaController::oneBundleConfigured()
{
	toolbar->Enable();
}

