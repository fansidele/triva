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
	reader = [[ProtoReader alloc] init];
	std::cout << "##" << __FUNCTION__ << std::endl;
	ProtoView *view = [[ProtoView alloc] init];
	[view step1];

	std::cout << "#########################################"<< std::endl;
	ogreInput = new OgreEventListener ((id)view);

	std::cout << mOgre << std::endl;
	mOgre->createRenderWindow ();
	std::cout << "#########################################"<< std::endl;
	mOgre->addInputListener (ogreInput);

	Ogre::RenderWindow *win = mOgre->getRenderWindow();
	[view createSceneManager];
	[view step4: win];
	simulator = [[OgreProtoSimulator alloc] init];


	[reader setOutput: simulator];
	[simulator setInput: reader];
	[simulator setOutput: view];
	[view setInput: simulator];
	this->setState(Initialized);
	mOgre->setRenderTimerPeriod (100);
}

TrivaController::TrivaController( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : TRIVAGUI (parent,id,title,pos,size,style)
{
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
	if (this->currentState() == Configured ||
		this->currentState() == Paused){
		this->setState(Running);
	}
}

void TrivaController::pauseClicked( wxCommandEvent& event )
{
	std::cout << __FUNCTION__ << std::endl;
	if (this->currentState() == Running){
		this->setState(Paused);
	}
}

void TrivaController::oneBundleConfigured()
{
	this->setState (Configured);
}

void TrivaController::checkRead(wxTimerEvent& event)
{
	if ([reader hasMoreData]){
		[reader read];
	}
}

void TrivaController::ogreRenderCheckbox( wxCommandEvent& event )
{
	std::cout << __FUNCTION__ << std::endl;
	if (renderCheckbox->IsChecked()){
		mOgre->resumeRenderTimer();
	}else{
		mOgre->pauseRenderTimer();
	}
}
