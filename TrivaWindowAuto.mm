///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "TrivaWindowAuto.h"

///////////////////////////////////////////////////////////////////////////

TrivaWindowAuto::TrivaWindowAuto( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	
	wxBoxSizer* bSizer1;
	bSizer1 = new wxBoxSizer( wxVERTICAL );
	
	squarifiedTreemap2Db = new wxToggleButton( this, wxID_ANY, wxT("Squarified Treemap (2D)"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer1->Add( squarifiedTreemap2Db, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	appCommunication3Db = new wxToggleButton( this, wxID_ANY, wxT("Application Communication Pattern (3D)"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer1->Add( appCommunication3Db, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	resourceComm3Db = new wxToggleButton( this, wxID_ANY, wxT("Resource and Application Pattern (3D)"), wxDefaultPosition, wxDefaultSize, 0 );
	resourceComm3Db->Enable( false );
	
	bSizer1->Add( resourceComm3Db, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	squarifiedTreemap3Db = new wxToggleButton( this, wxID_ANY, wxT("Squarified Treemap and Application Data(3D)"), wxDefaultPosition, wxDefaultSize, 0 );
	squarifiedTreemap3Db->Enable( false );
	
	bSizer1->Add( squarifiedTreemap3Db, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	memAccess2Db = new wxToggleButton( this, wxID_ANY, wxT("Memory Access (Simics - 2D)"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer1->Add( memAccess2Db, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	simgridb = new wxToggleButton( this, wxID_ANY, wxT("SIMGrid Simulation Visualization"), wxDefaultPosition, wxDefaultSize, 0 );
	simgridb->Enable( false );
	
	bSizer1->Add( simgridb, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	m_staticline1 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer1->Add( m_staticline1, 0, wxEXPAND | wxALL, 5 );
	
	exitb = new wxButton( this, wxID_ANY, wxT("Exit"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer1->Add( exitb, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	this->SetSizer( bSizer1 );
	this->Layout();
	
	// Connect Events
	squarifiedTreemap2Db->Connect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::squarifiedTreemap2D ), NULL, this );
	appCommunication3Db->Connect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::appCommunication3D ), NULL, this );
	resourceComm3Db->Connect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::resourceComm3D ), NULL, this );
	squarifiedTreemap3Db->Connect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::squarifiedTreemap3D ), NULL, this );
	memAccess2Db->Connect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::memAccess2D ), NULL, this );
	simgridb->Connect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::simgrid ), NULL, this );
	exitb->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::exit ), NULL, this );
}

TrivaWindowAuto::~TrivaWindowAuto()
{
	// Disconnect Events
	squarifiedTreemap2Db->Disconnect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::squarifiedTreemap2D ), NULL, this );
	appCommunication3Db->Disconnect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::appCommunication3D ), NULL, this );
	resourceComm3Db->Disconnect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::resourceComm3D ), NULL, this );
	squarifiedTreemap3Db->Disconnect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::squarifiedTreemap3D ), NULL, this );
	memAccess2Db->Disconnect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::memAccess2D ), NULL, this );
	simgridb->Disconnect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::simgrid ), NULL, this );
	exitb->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TrivaWindowAuto::exit ), NULL, this );
}
