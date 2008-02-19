///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Feb 12 2008)
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
	m_statusBar1 = this->CreateStatusBar( 1, wxST_SIZEGRIP, wxID_ANY );
	m_menubar1 = new wxMenuBar( wxMB_DOCKABLE );
	application = new wxMenu();
	wxMenuItem* loadbundle;
	loadbundle = new wxMenuItem( application, wxID_OPEN, wxString( wxT("&Load Bundle") ) , wxEmptyString, wxITEM_NORMAL );
	application->Append( loadbundle );
	
	wxMenuItem* exit;
	exit = new wxMenuItem( application, wxID_EXIT, wxString( wxT("&Quit") ) , wxT("Click to exit the application"), wxITEM_NORMAL );
	application->Append( exit );
	
	m_menubar1->Append( application, wxT("Application") );
	
	help = new wxMenu();
	wxMenuItem* about;
	about = new wxMenuItem( help, wxID_ABOUT, wxString( wxT("&About...") ) , wxEmptyString, wxITEM_NORMAL );
	help->Append( about );
	
	m_menubar1->Append( help, wxT("Help") );
	
	this->SetMenuBar( m_menubar1 );
	
	m_toolBar1 = this->CreateToolBar( wxTB_DOCKABLE|wxTB_HORIZONTAL, wxID_ANY ); 
	m_toolBar1->AddTool( wxID_ANY, wxT("Play"), wxNullBitmap, wxNullBitmap, wxITEM_NORMAL, wxEmptyString, wxT("Play") );
	m_toolBar1->AddTool( wxID_ANY, wxT("tool"), wxNullBitmap, wxNullBitmap, wxITEM_NORMAL, wxEmptyString, wxEmptyString );
	m_toolBar1->Realize();
	
	
	this->Centre( wxBOTH );
	
	// Connect Events
	this->Connect( loadbundle->GetId(), wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::loadbundle ) );
	this->Connect( exit->GetId(), wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::exit ) );
	this->Connect( about->GetId(), wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::about ) );
}

TRIVAGUI::~TRIVAGUI()
{
	// Disconnect Events
	this->Disconnect( wxID_ANY, wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::loadbundle ) );
	this->Disconnect( wxID_ANY, wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::exit ) );
	this->Disconnect( wxID_ANY, wxEVT_COMMAND_MENU_SELECTED, wxCommandEventHandler( TRIVAGUI::about ) );
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
