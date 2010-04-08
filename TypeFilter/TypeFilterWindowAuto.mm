///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "TypeFilterWindowAuto.h"

///////////////////////////////////////////////////////////////////////////

TypeFilterWindowAuto::TypeFilterWindowAuto( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	
	wxBoxSizer* bSizer1;
	bSizer1 = new wxBoxSizer( wxVERTICAL );
	
	wxGridBagSizer* gbSizer2;
	gbSizer2 = new wxGridBagSizer( 0, 0 );
	gbSizer2->AddGrowableCol( 0 );
	gbSizer2->AddGrowableRow( 0 );
	gbSizer2->SetFlexibleDirection( wxBOTH );
	gbSizer2->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	typeHierarchyCrtl = new wxTreeCtrl( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTR_DEFAULT_STYLE|wxTR_FULL_ROW_HIGHLIGHT|wxTR_HAS_BUTTONS|wxTR_LINES_AT_ROOT|wxTR_NO_LINES|wxTR_SINGLE|wxTR_TWIST_BUTTONS );
	gbSizer2->Add( typeHierarchyCrtl, wxGBPosition( 0, 0 ), wxGBSpan( 1, 1 ), wxALL|wxEXPAND, 5 );
	
	wxBoxSizer* bSizer2;
	bSizer2 = new wxBoxSizer( wxVERTICAL );
	
	mainCheckBox = new wxCheckBox( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	
	mainCheckBox->Enable( false );
	
	bSizer2->Add( mainCheckBox, 0, wxALL|wxEXPAND, 5 );
	
	wxArrayString checkListBoxChoices;
	checkListBox = new wxCheckListBox( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, checkListBoxChoices, 0 );
	checkListBox->Enable( false );
	
	bSizer2->Add( checkListBox, 1, wxALL|wxEXPAND, 5 );
	
	wxBoxSizer* bSizer5;
	bSizer5 = new wxBoxSizer( wxHORIZONTAL );
	
	m_textCtrl1 = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	bSizer5->Add( m_textCtrl1, 1, wxALL, 5 );
	
	m_button2 = new wxButton( this, wxID_ANY, wxT("Set"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer5->Add( m_button2, 0, wxALL, 5 );
	
	bSizer2->Add( bSizer5, 0, wxEXPAND, 5 );
	
	gbSizer2->Add( bSizer2, wxGBPosition( 0, 1 ), wxGBSpan( 1, 1 ), wxEXPAND, 5 );
	
	bSizer1->Add( gbSizer2, 1, wxEXPAND, 5 );
	
	this->SetSizer( bSizer1 );
	this->Layout();
	
	// Connect Events
	typeHierarchyCrtl->Connect( wxEVT_COMMAND_TREE_SEL_CHANGED, wxTreeEventHandler( TypeFilterWindowAuto::selectionChanged ), NULL, this );
	mainCheckBox->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( TypeFilterWindowAuto::mainCheckBoxClicked ), NULL, this );
	checkListBox->Connect( wxEVT_COMMAND_CHECKLISTBOX_TOGGLED, wxCommandEventHandler( TypeFilterWindowAuto::checkListBoxClicked ), NULL, this );
}

TypeFilterWindowAuto::~TypeFilterWindowAuto()
{
	// Disconnect Events
	typeHierarchyCrtl->Disconnect( wxEVT_COMMAND_TREE_SEL_CHANGED, wxTreeEventHandler( TypeFilterWindowAuto::selectionChanged ), NULL, this );
	mainCheckBox->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( TypeFilterWindowAuto::mainCheckBoxClicked ), NULL, this );
	checkListBox->Disconnect( wxEVT_COMMAND_CHECKLISTBOX_TOGGLED, wxCommandEventHandler( TypeFilterWindowAuto::checkListBoxClicked ), NULL, this );
}
