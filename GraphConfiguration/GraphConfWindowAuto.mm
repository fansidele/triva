///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "GraphConfWindowAuto.h"

///////////////////////////////////////////////////////////////////////////

GraphConfWindowAuto::GraphConfWindowAuto( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	
	wxBoxSizer* bSizer2;
	bSizer2 = new wxBoxSizer( wxVERTICAL );
	
	configuration = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxTE_MULTILINE );
	bSizer2->Add( configuration, 1, wxALL|wxEXPAND, 5 );
	
	wxBoxSizer* bSizer3;
	bSizer3 = new wxBoxSizer( wxHORIZONTAL );
	
	m_filePicker1 = new wxFilePickerCtrl( this, wxID_ANY, wxEmptyString, wxT("Select a file"), wxT("*.*"), wxDefaultPosition, wxDefaultSize, wxFLP_DEFAULT_STYLE );
	bSizer3->Add( m_filePicker1, 1, wxALL, 5 );
	
	apply = new wxButton( this, wxID_ANY, wxT("Apply"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer3->Add( apply, 0, wxALL|wxEXPAND, 5 );
	
	bSizer2->Add( bSizer3, 0, wxALIGN_RIGHT|wxEXPAND, 5 );
	
	this->SetSizer( bSizer2 );
	this->Layout();
	
	// Connect Events
	m_filePicker1->Connect( wxEVT_COMMAND_FILEPICKER_CHANGED, wxFileDirPickerEventHandler( GraphConfWindowAuto::loadFile ), NULL, this );
	apply->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( GraphConfWindowAuto::applyCurrentConfiguration ), NULL, this );
}

GraphConfWindowAuto::~GraphConfWindowAuto()
{
	// Disconnect Events
	m_filePicker1->Disconnect( wxEVT_COMMAND_FILEPICKER_CHANGED, wxFileDirPickerEventHandler( GraphConfWindowAuto::loadFile ), NULL, this );
	apply->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( GraphConfWindowAuto::applyCurrentConfiguration ), NULL, this );
}

GraphConfWindowAuto_Bak::GraphConfWindowAuto_Bak( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	
	wxBoxSizer* bSizer2;
	bSizer2 = new wxBoxSizer( wxVERTICAL );
	
	panels = new wxAuiNotebook( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxAUI_NB_DEFAULT_STYLE );
	
	bSizer2->Add( panels, 1, wxEXPAND | wxALL, 5 );
	
	wxBoxSizer* bSizer3;
	bSizer3 = new wxBoxSizer( wxHORIZONTAL );
	
	newconf = new wxButton( this, wxID_ANY, wxT("New Configuration"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer3->Add( newconf, 0, wxALL, 5 );
	
	apply = new wxButton( this, wxID_ANY, wxT("Apply"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer3->Add( apply, 0, wxALL, 5 );
	
	bSizer2->Add( bSizer3, 0, wxALIGN_RIGHT, 5 );
	
	this->SetSizer( bSizer2 );
	this->Layout();
	
	// Connect Events
	newconf->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( GraphConfWindowAuto_Bak::addNewConfigurationPanel ), NULL, this );
	apply->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( GraphConfWindowAuto_Bak::applyCurrentConfiguration ), NULL, this );
}

GraphConfWindowAuto_Bak::~GraphConfWindowAuto_Bak()
{
	// Disconnect Events
	newconf->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( GraphConfWindowAuto_Bak::addNewConfigurationPanel ), NULL, this );
	apply->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( GraphConfWindowAuto_Bak::applyCurrentConfiguration ), NULL, this );
}

GraphConfPanelAuto::GraphConfPanelAuto( wxWindow* parent, wxWindowID id, const wxPoint& pos, const wxSize& size, long style ) : wxPanel( parent, id, pos, size, style )
{
	wxBoxSizer* bSizer9;
	bSizer9 = new wxBoxSizer( wxVERTICAL );
	
	m_staticText20 = new wxStaticText( this, wxID_ANY, wxT("Available Information"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText20->Wrap( -1 );
	bSizer9->Add( m_staticText20, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	wxFlexGridSizer* fgSizer5;
	fgSizer5 = new wxFlexGridSizer( 1, 2, 0, 0 );
	fgSizer5->AddGrowableCol( 0 );
	fgSizer5->AddGrowableCol( 1 );
	fgSizer5->SetFlexibleDirection( wxBOTH );
	fgSizer5->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	wxBoxSizer* bSizer6;
	bSizer6 = new wxBoxSizer( wxVERTICAL );
	
	m_staticText13 = new wxStaticText( this, wxID_ANY, wxT("Containers"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText13->Wrap( -1 );
	bSizer6->Add( m_staticText13, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	containers = new wxListBox( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0, NULL, 0 ); 
	bSizer6->Add( containers, 1, wxALL|wxEXPAND, 5 );
	
	fgSizer5->Add( bSizer6, 0, wxEXPAND, 5 );
	
	wxBoxSizer* bSizer8;
	bSizer8 = new wxBoxSizer( wxVERTICAL );
	
	m_staticText14 = new wxStaticText( this, wxID_ANY, wxT("Variables/States"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText14->Wrap( -1 );
	bSizer8->Add( m_staticText14, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	values = new wxListBox( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0, NULL, 0 ); 
	bSizer8->Add( values, 1, wxALL|wxEXPAND, 5 );
	
	fgSizer5->Add( bSizer8, 0, wxEXPAND, 5 );
	
	bSizer9->Add( fgSizer5, 0, wxEXPAND, 5 );
	
	m_staticline2 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer9->Add( m_staticline2, 0, wxEXPAND | wxALL, 5 );
	
	m_staticText15 = new wxStaticText( this, wxID_ANY, wxT("Node Configuration"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText15->Wrap( -1 );
	bSizer9->Add( m_staticText15, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	wxFlexGridSizer* fgSizer7;
	fgSizer7 = new wxFlexGridSizer( 2, 2, 0, 0 );
	fgSizer7->AddGrowableCol( 1 );
	fgSizer7->SetFlexibleDirection( wxBOTH );
	fgSizer7->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	m_staticText16 = new wxStaticText( this, wxID_ANY, wxT("Nodes"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText16->Wrap( -1 );
	fgSizer7->Add( m_staticText16, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	nodes = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer7->Add( nodes, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText17 = new wxStaticText( this, wxID_ANY, wxT("Size"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText17->Wrap( -1 );
	fgSizer7->Add( m_staticText17, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	nodeSize = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer7->Add( nodeSize, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText18 = new wxStaticText( this, wxID_ANY, wxT("Position"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText18->Wrap( -1 );
	fgSizer7->Add( m_staticText18, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	nodePosition = new wxTextCtrl( this, wxID_ANY, wxT("GraphViz"), wxDefaultPosition, wxDefaultSize, 0 );
	nodePosition->Enable( false );
	
	fgSizer7->Add( nodePosition, 0, wxALL, 5 );
	
	m_staticText19 = new wxStaticText( this, wxID_ANY, wxT("Separation"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText19->Wrap( -1 );
	fgSizer7->Add( m_staticText19, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	nodeSeparation = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer7->Add( nodeSeparation, 0, wxALL|wxEXPAND, 5 );
	
	bSizer9->Add( fgSizer7, 0, wxEXPAND, 5 );
	
	m_staticline21 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer9->Add( m_staticline21, 0, wxEXPAND | wxALL, 5 );
	
	m_staticText151 = new wxStaticText( this, wxID_ANY, wxT("Edge Configuration"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText151->Wrap( -1 );
	bSizer9->Add( m_staticText151, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	wxFlexGridSizer* fgSizer4;
	fgSizer4 = new wxFlexGridSizer( 2, 2, 0, 0 );
	fgSizer4->AddGrowableCol( 1 );
	fgSizer4->SetFlexibleDirection( wxBOTH );
	fgSizer4->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	m_staticText8 = new wxStaticText( this, wxID_ANY, wxT("Edges"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText8->Wrap( -1 );
	fgSizer4->Add( m_staticText8, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	edges = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer4->Add( edges, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText9 = new wxStaticText( this, wxID_ANY, wxT("Size"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText9->Wrap( -1 );
	fgSizer4->Add( m_staticText9, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	edgeSize = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer4->Add( edgeSize, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText11 = new wxStaticText( this, wxID_ANY, wxT("Separation"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText11->Wrap( -1 );
	fgSizer4->Add( m_staticText11, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	edgeSeparation = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer4->Add( edgeSeparation, 0, wxALL|wxEXPAND, 5 );
	
	bSizer9->Add( fgSizer4, 1, wxEXPAND, 5 );
	
	this->SetSizer( bSizer9 );
	this->Layout();
}

GraphConfPanelAuto::~GraphConfPanelAuto()
{
}
