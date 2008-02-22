///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Feb 21 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "wxOgreRenderWindow.h"

#include "TRIVAGUI.h"

///////////////////////////////////////////////////////////////////////////

TRIVAGUI::TRIVAGUI( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	
	wxBoxSizer* bSizer3;
	bSizer3 = new wxBoxSizer( wxVERTICAL );
	
	mOgre = new wxOgreRenderWindow( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL );
	bSizer3->Add( mOgre, 1, wxEXPAND|wxALL|wxALIGN_CENTER_HORIZONTAL, 0 );
	
	this->SetSizer( bSizer3 );
	this->Layout();
	m_menubar2 = new wxMenuBar( 0 );
	application = new wxMenu();
	wxMenuItem* m_menuItem6;
	m_menuItem6 = new wxMenuItem( application, wxID_OPEN, wxString( wxT("Load &KAAPI Bundle") ) , wxEmptyString, wxITEM_NORMAL );
	application->Append( m_menuItem6 );
	
	wxMenuItem* m_menuItem5;
	m_menuItem5 = new wxMenuItem( application, wxID_EXIT, wxString( wxT("E&xit") ) , wxEmptyString, wxITEM_NORMAL );
	application->Append( m_menuItem5 );
	
	m_menubar2->Append( application, wxT("Application") );
	
	m_menu6 = new wxMenu();
	wxMenuItem* m_menuItem9;
	m_menuItem9 = new wxMenuItem( m_menu6, wxID_ABOUT, wxString( wxT("About...") ) , wxEmptyString, wxITEM_NORMAL );
	m_menu6->Append( m_menuItem9 );
	
	m_menubar2->Append( m_menu6, wxT("Help") );
	
	this->SetMenuBar( m_menubar2 );
	
	toolbar = this->CreateToolBar( wxTB_NOICONS|wxTB_TEXT, wxID_ANY ); 
	playButton = new wxButton( toolbar, wxID_ANY, wxT("Play"), wxDefaultPosition, wxDefaultSize, 0 );
	toolbar->AddControl( playButton );
	pauseButton = new wxButton( toolbar, wxID_ANY, wxT("Pause"), wxDefaultPosition, wxDefaultSize, 0 );
	toolbar->AddControl( pauseButton );
	toolbar->Realize();
	
	
	this->Centre( wxBOTH );
	
	// Connect Events
	this->Connect( m_menuItem6->GetId(), wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::loadBundle ) );
	this->Connect( m_menuItem5->GetId(), wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::exit ) );
	this->Connect( m_menuItem9->GetId(), wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::about ) );
	playButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TRIVAGUI::playClicked ), NULL, this );
	pauseButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TRIVAGUI::pauseClicked ), NULL, this );
}

TRIVAGUI::~TRIVAGUI()
{
	// Disconnect Events
	this->Disconnect( wxID_ANY, wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::loadBundle ) );
	this->Disconnect( wxID_ANY, wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::exit ) );
	this->Disconnect( wxID_ANY, wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::about ) );
	playButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TRIVAGUI::playClicked ), NULL, this );
	pauseButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TRIVAGUI::pauseClicked ), NULL, this );
}

TrivaAboutGui::TrivaAboutGui( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxSize( 400,150 ), wxSize( 400,150 ) );
	
	wxFlexGridSizer* fgSizer1;
	fgSizer1 = new wxFlexGridSizer( 2, 2, 0, 0 );
	fgSizer1->SetFlexibleDirection( wxBOTH );
	fgSizer1->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	m_bitmap3 = new wxStaticBitmap( this, wxID_ANY, wxNullBitmap, wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer1->Add( m_bitmap3, 0, wxALL, 5 );
	
	m_staticText1 = new wxStaticText( this, wxID_ANY, wxT("TRIVA\nThRee dimensional Interactive Visualization Analysis\n\nReleased under GPL v3.0\n\nLucas Mello Schnorr\nschnorr@gmail.com"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText1->Wrap( -1 );
	m_staticText1->SetBackgroundColour( wxSystemSettings::GetColour( wxSYS_COLOUR_HIGHLIGHT ) );
	
	fgSizer1->Add( m_staticText1, 0, wxALL, 5 );
	
	this->SetSizer( fgSizer1 );
	this->Layout();
	
	this->Centre( wxBOTH );
}

TrivaAboutGui::~TrivaAboutGui()
{
}

BundleGUI::BundleGUI( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	
	wxBoxSizer* bSizer12;
	bSizer12 = new wxBoxSizer( wxVERTICAL );
	
	m_notebook2 = new wxNotebook( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0 );
	m_panel9 = new wxPanel( m_notebook2, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL );
	wxBoxSizer* bSizer13;
	bSizer13 = new wxBoxSizer( wxVERTICAL );
	
	selectTraceButton = new wxButton( m_panel9, wxID_ANY, wxT("(Select Trace Files)"), wxDefaultPosition, wxDefaultSize, wxBU_LEFT );
	selectTraceButton->SetBackgroundColour( wxColour( 152, 198, 229 ) );
	
	bSizer13->Add( selectTraceButton, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText5 = new wxStaticText( m_panel9, wxID_ANY, wxT("Trace"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText5->Wrap( -1 );
	bSizer13->Add( m_staticText5, 0, wxALL|wxEXPAND, 5 );
	
	traceFileOpened = new wxListBox( m_panel9, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0, NULL, wxLB_ALWAYS_SB|wxLB_MULTIPLE ); 
	bSizer13->Add( traceFileOpened, 1, wxALL|wxEXPAND, 5 );
	
	removeTraceFileButton = new wxButton( m_panel9, wxID_ANY, wxT("Remove"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer13->Add( removeTraceFileButton, 0, wxALL, 5 );
	
	m_panel9->SetSizer( bSizer13 );
	m_panel9->Layout();
	bSizer13->Fit( m_panel9 );
	m_notebook2->AddPage( m_panel9, wxT("&Trace Files"), true );
	m_panel10 = new wxPanel( m_notebook2, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL );
	wxBoxSizer* bSizer131;
	bSizer131 = new wxBoxSizer( wxVERTICAL );
	
	selectSyncButton = new wxButton( m_panel10, wxID_ANY, wxT("(Select Sync File)"), wxDefaultPosition, wxDefaultSize, wxBU_LEFT );
	selectSyncButton->SetBackgroundColour( wxColour( 152, 198, 229 ) );
	
	bSizer131->Add( selectSyncButton, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText51 = new wxStaticText( m_panel10, wxID_ANY, wxT("Sync"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText51->Wrap( -1 );
	bSizer131->Add( m_staticText51, 0, wxALL|wxEXPAND, 5 );
	
	syncFileOpened = new wxListBox( m_panel10, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0, NULL, 0 ); 
	bSizer131->Add( syncFileOpened, 1, wxALL|wxEXPAND, 5 );
	
	removeSyncFileButton = new wxButton( m_panel10, wxID_ANY, wxT("Remove"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer131->Add( removeSyncFileButton, 0, wxALL, 5 );
	
	m_panel10->SetSizer( bSizer131 );
	m_panel10->Layout();
	bSizer131->Fit( m_panel10 );
	m_notebook2->AddPage( m_panel10, wxT("&Synchronization File"), false );
	m_panel11 = new wxPanel( m_notebook2, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL );
	wxBoxSizer* bSizer17;
	bSizer17 = new wxBoxSizer( wxVERTICAL );
	
	wxGridSizer* gSizer4;
	gSizer4 = new wxGridSizer( 1, 1, 0, 0 );
	
	statusText = new wxTextCtrl( m_panel11, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxHSCROLL|wxTE_CAPITALIZE|wxTE_CENTRE|wxTE_READONLY );
	statusText->SetFont( wxFont( 22, 77, 90, 92, false, wxT("Verdana") ) );
	statusText->SetForegroundColour( wxColour( 5, 255, 1 ) );
	
	gSizer4->Add( statusText, 0, wxALL|wxEXPAND, 5 );
	
	bSizer17->Add( gSizer4, 5, wxEXPAND, 5 );
	
	wxGridSizer* gSizer6;
	gSizer6 = new wxGridSizer( 1, 3, 0, 0 );
	
	
	gSizer6->Add( 0, 0, 1, wxEXPAND, 5 );
	
	
	gSizer6->Add( 0, 0, 1, wxEXPAND, 5 );
	
	activateButton = new wxButton( m_panel11, wxID_ANY, wxT("Activate"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer6->Add( activateButton, 0, wxALL|wxEXPAND, 5 );
	
	bSizer17->Add( gSizer6, 1, wxEXPAND, 5 );
	
	m_panel11->SetSizer( bSizer17 );
	m_panel11->Layout();
	bSizer17->Fit( m_panel11 );
	m_notebook2->AddPage( m_panel11, wxT("&Activation && Status"), false );
	
	bSizer12->Add( m_notebook2, 1, wxEXPAND | wxALL, 5 );
	
	this->SetSizer( bSizer12 );
	this->Layout();
	
	this->Centre( wxBOTH );
	
	// Connect Events
	selectTraceButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::traceFilePicker ), NULL, this );
	removeTraceFileButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::removeTraceFile ), NULL, this );
	selectSyncButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::syncFilePicker ), NULL, this );
	removeSyncFileButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::removeSyncFile ), NULL, this );
	activateButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::activate ), NULL, this );
}

BundleGUI::~BundleGUI()
{
	// Disconnect Events
	selectTraceButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::traceFilePicker ), NULL, this );
	removeTraceFileButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::removeTraceFile ), NULL, this );
	selectSyncButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::syncFilePicker ), NULL, this );
	removeSyncFileButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::removeSyncFile ), NULL, this );
	activateButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( BundleGUI::activate ), NULL, this );
}
