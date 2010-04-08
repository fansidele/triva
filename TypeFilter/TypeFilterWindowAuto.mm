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
	
	wxBoxSizer* bSizer4;
	bSizer4 = new wxBoxSizer( wxHORIZONTAL );
	
	typeHierarchyCrtl = new wxTreeCtrl( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTR_DEFAULT_STYLE|wxTR_FULL_ROW_HIGHLIGHT|wxTR_HAS_BUTTONS|wxTR_LINES_AT_ROOT|wxTR_NO_LINES|wxTR_SINGLE|wxTR_TWIST_BUTTONS );
	bSizer4->Add( typeHierarchyCrtl, 1, wxALL|wxEXPAND, 5 );
	
	wxBoxSizer* bSizer2;
	bSizer2 = new wxBoxSizer( wxVERTICAL );
	
	mainCheckBox = new wxCheckBox( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, 0 );
	
	mainCheckBox->Enable( false );
	
	bSizer2->Add( mainCheckBox, 0, wxALL|wxEXPAND, 5 );
	
	wxArrayString checkListBoxChoices;
	checkListBox = new wxCheckListBox( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, checkListBoxChoices, wxLB_EXTENDED );
	checkListBox->Enable( false );
	
	bSizer2->Add( checkListBox, 1, wxALL|wxEXPAND, 5 );
	
	wxBoxSizer* bSizer5;
	bSizer5 = new wxBoxSizer( wxHORIZONTAL );
	
	regExpr = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxTE_PROCESS_ENTER );
	bSizer5->Add( regExpr, 1, wxALL, 5 );
	
	bSizer2->Add( bSizer5, 0, wxEXPAND, 5 );
	
	bSizer4->Add( bSizer2, 1, wxEXPAND, 5 );
	
	this->SetSizer( bSizer4 );
	this->Layout();
	
	// Connect Events
	typeHierarchyCrtl->Connect( wxEVT_COMMAND_TREE_SEL_CHANGED, wxTreeEventHandler( TypeFilterWindowAuto::selectionChanged ), NULL, this );
	mainCheckBox->Connect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( TypeFilterWindowAuto::mainCheckBoxClicked ), NULL, this );
	checkListBox->Connect( wxEVT_COMMAND_CHECKLISTBOX_TOGGLED, wxCommandEventHandler( TypeFilterWindowAuto::checkListBoxClicked ), NULL, this );
	regExpr->Connect( wxEVT_COMMAND_TEXT_UPDATED, wxCommandEventHandler( TypeFilterWindowAuto::updateRegularExpr ), NULL, this );
	regExpr->Connect( wxEVT_COMMAND_TEXT_ENTER, wxCommandEventHandler( TypeFilterWindowAuto::checkBasedOnRegularExpr ), NULL, this );
}

TypeFilterWindowAuto::~TypeFilterWindowAuto()
{
	// Disconnect Events
	typeHierarchyCrtl->Disconnect( wxEVT_COMMAND_TREE_SEL_CHANGED, wxTreeEventHandler( TypeFilterWindowAuto::selectionChanged ), NULL, this );
	mainCheckBox->Disconnect( wxEVT_COMMAND_CHECKBOX_CLICKED, wxCommandEventHandler( TypeFilterWindowAuto::mainCheckBoxClicked ), NULL, this );
	checkListBox->Disconnect( wxEVT_COMMAND_CHECKLISTBOX_TOGGLED, wxCommandEventHandler( TypeFilterWindowAuto::checkListBoxClicked ), NULL, this );
	regExpr->Disconnect( wxEVT_COMMAND_TEXT_UPDATED, wxCommandEventHandler( TypeFilterWindowAuto::updateRegularExpr ), NULL, this );
	regExpr->Disconnect( wxEVT_COMMAND_TEXT_ENTER, wxCommandEventHandler( TypeFilterWindowAuto::checkBasedOnRegularExpr ), NULL, this );
}
