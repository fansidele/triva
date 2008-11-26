#include "TrivaController.h"
#include <wx/colordlg.h>

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

std::string WXSTRINGtoSTDSTRING (wxString wsa)
{
	char sa[100];
	snprintf (sa, 100, "%S", wsa.c_str());
	return std::string(sa);
}

TrivaController::TrivaController( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : AutoGUI_Triva (parent,id,title,pos,size,style)
{
	/* last ogre initialization that cannot be accomplished before */
//	Ogre::Root *mRoot = Ogre::Root::getSingletonPtr ();

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

	trivaPaje = [[TrivaPajeComponent alloc] init];
	view = (ProtoView *) [trivaPaje componentWithName: @"ProtoView"];
	reader = (TrivaPajeReader *) [trivaPaje componentWithName: @"TrivaPajeReader"];
	fusion = (TrivaFusion *) [trivaPaje componentWithName: @"TrivaFusion"];
	[view drawManager]->setTrivaController(this);
	NSLog (@"trivaPajeComponent = %@", [trivaPaje description]);
	NSLog (@"pajeReader = %@", reader);
	NSLog (@"pajeView = %@", view);
	NSLog (@"fusion = %@", fusion);

	guiPreferencesWindow = new GUI_Preferences(this);
	guiPreferencesWindow->setController (this);

	/* configuring 2d frame */
	timeslice = [trivaPaje componentWithName: @"TimeSlice"];
	m2DFrame->setController (this);

	/* configuring 3d frame */
	m3DFrame->addInputListener (cameraManager);
	m3DFrame->addInputListener ([view drawManager]);
	m3DFrame->setRenderTimerPeriod (5,true);
	m3DFrame->setListenersEnabled (true, false);

	/* configuring other GUI objects */
	this->configureZoom();
	m3DFrame->pauseRenderTimer();

	/* set application instance state to Initialized */
	this->setState(Initialized);

	selectedObject = NULL;
	selectedEntity = nil;

	/* configuration of other windows */
	guiBaseWindow = new GUI_Base(this);
	guiBaseWindow->setController (this);

	guiCombinedCounterWindow = new GUI_CombinedCounter (this);
	guiCombinedCounterWindow->setController (this);


	m3DFrame->SetFocus();

	/* configuring scrollbar */
	timeWindow = 0;
	scrollbarPosition = 0;
	scrollbarRange = 0;
	scrollbarPage = 0;
	this->adjustScrollbar();
}

TrivaController::~TrivaController()
{
	std::cout << "#### " << __FUNCTION__ << std::endl;
	[reader release];
	[view release];
	m3DFrame->removeInputListener(cameraManager);
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
	AutoGUI_About *win = new AutoGUI_About (0, wxID_ANY);
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
	if (this->currentState() == Running){
		[view hierarchyChanged];
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
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	static int flag = 1;
	if (flag){
		flag = [trivaPaje readNextChunk: nil];
	}else{
		this->applicationIsPaused();
		static int flag = 0;
		if (!flag){
			[view hierarchyChanged];
			flag = 1;
		}
	}
	[pool release];
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

void TrivaController::changeColor( wxCommandEvent& event )
{
	//check if anything is selected

	//pega cor existente
	wxColourData data;
	wxColor color;
	data.SetColour(color);

	NSLog (@"selectedEntity = %@", selectedEntity);

	wxColour x = wxGetColourFromUser(this, color);
	colorButton->SetBackgroundColour (x);
	DrawManager *m = [view drawManager];
	std::string str = std::string (colorButton->GetLabel().ToAscii());
	Ogre::ColourValue og = this->convertWxColor (x);
	m->setMaterialColor (str, og);
	m->registerColor (std::string([[[selectedEntity entityType] name]
cString]), std::string([[selectedEntity name] cString]), og);
}

void TrivaController::mergeSelected (wxCommandEvent& event)
{
NS_DURING
	[fusion mergeSelectedContainers];
NS_HANDLER
        NSLog (@"Exception = %@", localException);
        wxString m = NSSTRINGtoWXSTRING ([localException reason]);
        wxString n = NSSTRINGtoWXSTRING ([localException name]);
        wxMessageDialog *dial = new wxMessageDialog(NULL, m, n, wxOK |
wxICON_ERROR);
        dial->ShowModal();
NS_ENDHANDLER
}

void TrivaController::fullscreenSelection (wxCommandEvent& event )
{
	if (this->IsFullScreen()){
		this->ShowFullScreen (false);
	}else{
		this->ShowFullScreen (true);
	}
}

void TrivaController::viewSwitchSelection ()
{
	if (m3DFrame->IsShown()){
		m3DFrame->Show(false);
		m3DFrame->pauseRenderTimer();

		m2DFrame->Show(true);
	}else{
		m3DFrame->Show(true);
		m3DFrame->resumeRenderTimer();

		m2DFrame->Show(false);
	}
}

void TrivaController::viewSwitchSelection (wxCommandEvent& event )
{
	this->viewSwitchSelection();
}

void TrivaController::guiBaseSelection( wxCommandEvent& event )
{
	if (guiBaseWindow->IsShown()){
		guiBaseWindow->Hide();
	}else{
		guiBaseWindow->Show();
	}
}

void TrivaController::guiCombinedCounterSelection( wxCommandEvent& event )
{
	if (guiCombinedCounterWindow->IsShown()){
		guiCombinedCounterWindow->Hide();
	}else{
		guiCombinedCounterWindow->Show();
	}
}

void TrivaController::guiPreferencesSelection( wxCommandEvent& event )
{
	if (guiPreferencesWindow->IsShown()){
		guiPreferencesWindow->Hide();
	}else{
		guiPreferencesWindow->Show();
	}
}

void TrivaController::openPajeTraceFile ( wxCommandEvent& event )
{
	wxFileDialog *f = new wxFileDialog (NULL, wxT("Choose Paje Trace File"),
						wxT(""), wxT(""),
						wxT("*.trace"),
						wxOPEN|wxFILE_MUST_EXIST,
						wxDefaultPosition);

	if (f->ShowModal() == wxID_OK){
		this->openPajeTraceFile (f->GetPath());
	}
}

void TrivaController::openPajeTraceFile (wxString path)
{
	NSString *filename = WXSTRINGtoNSSTRING (path);
	id reader = [trivaPaje componentWithName: @"FileReader"];
	[reader setInputFilename: filename];
	[trivaPaje setReaderWithName: @"FileReader"];
	this->setState (Configured);
	this->setState (Running);
}
