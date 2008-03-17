#include "TrivaController.h"

wxString NSSTRINGtoWXSTRING (NSString *ns)
{
	if (ns == nil){
		return wxString();
	}
	return wxString::FromAscii ([ns cString]);
}

NSString *WXSTRINGtoNSSTRING (wxString wsa)
{
	char sa[100];
	snprintf (sa, 100, "%S", wsa.c_str());
	return [NSString stringWithFormat:@"%s", sa];
}

TrivaController::TrivaController( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : TrivaAutoGeneratedGUI (parent,id,title,pos,size,style)
{
	/* last ogre initialization that cannot be accomplished before */
	Ogre::Root *mRoot = Ogre::Root::getSingletonPtr ();

	NSString *resourcescfg = [[NSBundle mainBundle] pathForResource:
@"resources" ofType: @"cfg"];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *currentPath = [fm currentDirectoryPath];
        NSArray *ar = [resourcescfg pathComponents];
        NSMutableArray *ar2 = [NSMutableArray arrayWithArray: ar];
        [ar2 removeLastObject];
        NSString *mediaPath = [NSString pathWithComponents: ar2];
	[fm changeCurrentDirectoryPath: mediaPath];
	Ogre::ResourceGroupManager *resource;
	resource = Ogre::ResourceGroupManager::getSingletonPtr();
	resource->initialiseAllResourceGroups();
	[fm changeCurrentDirectoryPath: currentPath];


	/* initializing visual objects */
	cameraManager = new CameraManager (this, m3DFrame->getRenderWindow());
	ambientManager = new AmbientManager ();
	selectorManager = new SelectorManager (this);

	/* configuring 3d frame */
	m3DFrame->addInputListener (cameraManager);
	m3DFrame->addInputListener (selectorManager);
	m3DFrame->setRenderTimerPeriod (5,true);
	m3DFrame->setListenersEnabled (true, false);

	/* configuring other GUI objects */
	this->configureZoom();
	m3DFrame->pauseRenderTimer();

	/* configuring color window */
	colorWindow = new TrivaColorWindowEvents(0,wxID_ANY);

	/* configuring reader, simulator and inner view */
/*
	reader = [[ProtoReader alloc] init];
	simulator = [[OgreProtoSimulator alloc] init];
	view = [[ProtoView alloc] init];
*/

/*
	[reader setOutput: simulator];
	[simulator setInput: reader];
	[simulator setOutput: view];
	[view setInput: simulator];
*/


	trivaPaje = [[TrivaPajeComponent alloc] init];
//	[trivaPaje setController: this];
	view =[ProtoView componentWithController:trivaPaje];
	[view initialize];
	reader = [[TrivaPajeReader alloc] initWithController: trivaPaje];
	[trivaPaje setOutputFilter: view];
	[trivaPaje setInputFilter: reader];
	NSLog (@"trivaPajeComponent = %@", [trivaPaje description]);
	NSLog (@"pajeReader = %@", reader);
	NSLog (@"pajeView = %@", view);

	/* set application instance state to Initialized */
	this->setState(Initialized);

}

TrivaController::~TrivaController()
{
	std::cout << "#### " << __FUNCTION__ << std::endl;
	[reader release];
/*
	[simulator release];
*/
	[view release];
	m3DFrame->removeInputListener(cameraManager);
	colorWindow->Close();
	delete ambientManager;
	delete cameraManager;
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
NS_DURING
	[trivaPaje readNextChunk: nil];
/*
	if ([reader hasMoreData]){
		[reader read];
	}
*/
NS_HANDLER
        NSLog (@"Exception = %@", localException);
        wxString m = NSSTRINGtoWXSTRING ([localException reason]);
        wxString n = NSSTRINGtoWXSTRING ([localException name]);
        wxMessageDialog *dial = new wxMessageDialog(NULL, m, n, wxOK |
wxICON_ERROR);
        dial->ShowModal();
	this->setState(Paused);
NS_ENDHANDLER
}

void TrivaController::openColorWindow( wxCommandEvent& event )
{
	colorWindow->Show();
}
