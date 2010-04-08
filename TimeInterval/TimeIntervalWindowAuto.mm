///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "TimeIntervalWindowAuto.h"

///////////////////////////////////////////////////////////////////////////

TimeIntervalWindowAuto::TimeIntervalWindowAuto( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxSize( 300,400 ), wxSize( 300,400 ) );
	this->Enable( false );
	
	wxBoxSizer* bSizer2;
	bSizer2 = new wxBoxSizer( wxVERTICAL );
	
	wxFlexGridSizer* fgSizer2;
	fgSizer2 = new wxFlexGridSizer( 2, 2, 0, 0 );
	fgSizer2->SetFlexibleDirection( wxBOTH );
	fgSizer2->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	m_staticText1 = new wxStaticText( this, wxID_ANY, wxT("Trace Start Time:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText1->Wrap( -1 );
	fgSizer2->Add( m_staticText1, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT, 5 );
	
	traceStartTime = new wxStaticText( this, wxID_ANY, wxT("0"), wxDefaultPosition, wxDefaultSize, 0 );
	traceStartTime->Wrap( -1 );
	fgSizer2->Add( traceStartTime, 1, wxALL, 5 );
	
	m_staticText3 = new wxStaticText( this, wxID_ANY, wxT("Trace End Time:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText3->Wrap( -1 );
	fgSizer2->Add( m_staticText3, 0, wxALL|wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL, 5 );
	
	traceEndTime = new wxStaticText( this, wxID_ANY, wxT("0"), wxDefaultPosition, wxDefaultSize, 0 );
	traceEndTime->Wrap( -1 );
	fgSizer2->Add( traceEndTime, 0, wxALL|wxEXPAND, 5 );
	
	bSizer2->Add( fgSizer2, 0, wxEXPAND, 5 );
	
	
	bSizer2->Add( 0, 20, 0, wxEXPAND, 5 );
	
	m_staticline3 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer2->Add( m_staticline3, 0, wxEXPAND|wxALL, 5 );
	
	wxBoxSizer* bSizer4;
	bSizer4 = new wxBoxSizer( wxVERTICAL );
	
	wxGridSizer* gSizer1;
	gSizer1 = new wxGridSizer( 1, 2, 0, 0 );
	
	m_staticText4 = new wxStaticText( this, wxID_ANY, wxT("Time Selection Start:"), wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE );
	m_staticText4->Wrap( -1 );
	gSizer1->Add( m_staticText4, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	timeSelectionStart = new wxStaticText( this, wxID_ANY, wxT("0"), wxDefaultPosition, wxDefaultSize, 0 );
	timeSelectionStart->Wrap( -1 );
	gSizer1->Add( timeSelectionStart, 0, wxALL, 5 );
	
	bSizer4->Add( gSizer1, 0, 0, 5 );
	
	timeSelectionStartSlider = new wxSlider( this, wxID_ANY, 0, 0, 100, wxDefaultPosition, wxDefaultSize, wxSL_HORIZONTAL );
	bSizer4->Add( timeSelectionStartSlider, 0, wxALL|wxEXPAND, 5 );
	
	m_staticline4 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer4->Add( m_staticline4, 0, wxEXPAND | wxALL, 5 );
	
	wxGridSizer* gSizer2;
	gSizer2 = new wxGridSizer( 1, 2, 0, 0 );
	
	m_staticText5 = new wxStaticText( this, wxID_ANY, wxT("Time Selection End:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText5->Wrap( -1 );
	gSizer2->Add( m_staticText5, 0, wxALL|wxEXPAND|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	timeSelectionEnd = new wxStaticText( this, wxID_ANY, wxT("0"), wxDefaultPosition, wxDefaultSize, 0 );
	timeSelectionEnd->Wrap( -1 );
	gSizer2->Add( timeSelectionEnd, 0, wxALL, 5 );
	
	bSizer4->Add( gSizer2, 0, 0, 5 );
	
	timeSelectionEndSlider = new wxSlider( this, wxID_ANY, 0, 0, 100, wxDefaultPosition, wxDefaultSize, wxSL_HORIZONTAL );
	bSizer4->Add( timeSelectionEndSlider, 0, wxEXPAND|wxALL, 5 );
	
	wxGridSizer* gSizer3;
	gSizer3 = new wxGridSizer( 1, 3, 0, 0 );
	
	
	gSizer3->Add( 0, 0, 1, wxEXPAND, 5 );
	
	m_staticText9 = new wxStaticText( this, wxID_ANY, wxT("Forward (s)"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText9->Wrap( -1 );
	gSizer3->Add( m_staticText9, 0, wxALL|wxALIGN_BOTTOM|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	m_staticText10 = new wxStaticText( this, wxID_ANY, wxT("Frequency (s)"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText10->Wrap( -1 );
	gSizer3->Add( m_staticText10, 0, wxALL|wxALIGN_BOTTOM|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	playButton = new wxToggleButton( this, wxID_ANY, wxT("Play"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer3->Add( playButton, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	m_textCtrl1 = new wxTextCtrl( this, wxID_ANY, wxT("1"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer3->Add( m_textCtrl1, 1, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	m_textCtrl2 = new wxTextCtrl( this, wxID_ANY, wxT("0.05"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer3->Add( m_textCtrl2, 0, wxALL, 5 );
	
	bSizer4->Add( gSizer3, 0, wxEXPAND, 5 );
	
	bSizer2->Add( bSizer4, 1, wxEXPAND, 5 );
	
	m_staticline11 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer2->Add( m_staticline11, 0, wxEXPAND | wxALL, 5 );
	
	m_button1 = new wxButton( this, wxID_ANY, wxT("Apply"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer2->Add( m_button1, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	this->SetSizer( bSizer2 );
	this->Layout();
	
	// Connect Events
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Connect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Connect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	playButton->Connect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::play ), NULL, this );
	m_textCtrl1->Connect( wxEVT_COMMAND_TEXT_ENTER, wxCommandEventHandler( TimeIntervalWindowAuto::timeStep ), NULL, this );
	m_button1->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::apply ), NULL, this );
}

TimeIntervalWindowAuto::~TimeIntervalWindowAuto()
{
	// Disconnect Events
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionStartSlider->Disconnect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::startScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	timeSelectionEndSlider->Disconnect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::endScroll ), NULL, this );
	playButton->Disconnect( wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::play ), NULL, this );
	m_textCtrl1->Disconnect( wxEVT_COMMAND_TEXT_ENTER, wxCommandEventHandler( TimeIntervalWindowAuto::timeStep ), NULL, this );
	m_button1->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::apply ), NULL, this );
}
