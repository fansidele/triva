///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "SliceDraw.h"

#include "TimeIntervalWindowAuto.h"

///////////////////////////////////////////////////////////////////////////

TimeIntervalWindowAuto::TimeIntervalWindowAuto( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	
	wxBoxSizer* bSizer8;
	bSizer8 = new wxBoxSizer( wxVERTICAL );
	
	wxGridSizer* gSizer14;
	gSizer14 = new wxGridSizer( 1, 3, 0, 0 );
	
	m_staticText73 = new wxStaticText( this, wxID_ANY, wxT("Trace Time:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText73->Wrap( -1 );
	gSizer14->Add( m_staticText73, 0, wxALL, 5 );
	
	traceStartTime = new wxStaticText( this, wxID_ANY, wxT("0"), wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE );
	traceStartTime->Wrap( -1 );
	traceStartTime->SetFont( wxFont( wxNORMAL_FONT->GetPointSize(), 70, 90, 90, false, wxEmptyString ) );
	
	gSizer14->Add( traceStartTime, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	traceEndTime = new wxStaticText( this, wxID_ANY, wxT("0"), wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE );
	traceEndTime->Wrap( -1 );
	traceEndTime->SetFont( wxFont( wxNORMAL_FONT->GetPointSize(), 70, 90, 90, false, wxEmptyString ) );
	
	gSizer14->Add( traceEndTime, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	bSizer8->Add( gSizer14, 0, wxALIGN_CENTER_HORIZONTAL|wxEXPAND, 5 );
	
	m_staticline11 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer8->Add( m_staticline11, 0, wxEXPAND | wxALL, 5 );
	
	wxBoxSizer* bSizer24;
	bSizer24 = new wxBoxSizer( wxVERTICAL );
	
	timeSliceCheckBox = new wxCheckBox( this, wxID_ANY, wxT("Time Slice"), wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT );
	
	timeSliceCheckBox->SetToolTip( wxT("Check here to update the visualization\nmodules when the time slice is update.") );
	
	bSizer24->Add( timeSliceCheckBox, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	bSizer8->Add( bSizer24, 0, wxEXPAND, 5 );
	
	wxFlexGridSizer* fgSizer5;
	fgSizer5 = new wxFlexGridSizer( 2, 2, 0, 0 );
	fgSizer5->AddGrowableCol( 1 );
	fgSizer5->SetFlexibleDirection( wxBOTH );
	fgSizer5->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	m_staticText4 = new wxStaticText( this, wxID_ANY, wxT("Start"), wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE );
	m_staticText4->Wrap( -1 );
	fgSizer5->Add( m_staticText4, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT, 5 );
	
	startSlider = new wxSlider( this, wxID_ANY, 0, 0, 100, wxDefaultPosition, wxDefaultSize, wxSL_HORIZONTAL );
	fgSizer5->Add( startSlider, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxEXPAND, 5 );
	
	m_staticText83 = new wxStaticText( this, wxID_ANY, wxT("Size"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText83->Wrap( -1 );
	fgSizer5->Add( m_staticText83, 0, wxALL|wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL, 5 );
	
	sizeSlider = new wxSlider( this, wxID_ANY, 0, 0, 100, wxDefaultPosition, wxDefaultSize, wxSL_HORIZONTAL );
	fgSizer5->Add( sizeSlider, 0, wxEXPAND|wxALL, 5 );
	
	bSizer8->Add( fgSizer5, 0, wxEXPAND, 5 );
	
	wxGridSizer* gSizer15;
	gSizer15 = new wxGridSizer( 1, 3, 0, 0 );
	
	timeSelectionStart = new wxStaticText( this, wxID_ANY, wxT("0"), wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE );
	timeSelectionStart->Wrap( -1 );
	timeSelectionStart->SetFont( wxFont( wxNORMAL_FONT->GetPointSize(), 70, 90, 90, false, wxEmptyString ) );
	
	gSizer15->Add( timeSelectionStart, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	timeSelectionEnd = new wxStaticText( this, wxID_ANY, wxT("0"), wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE );
	timeSelectionEnd->Wrap( -1 );
	timeSelectionEnd->SetFont( wxFont( wxNORMAL_FONT->GetPointSize(), 70, 90, 90, false, wxEmptyString ) );
	
	gSizer15->Add( timeSelectionEnd, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	m_button4 = new wxButton( this, wxID_ANY, wxT("Apply"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer15->Add( m_button4, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	bSizer8->Add( gSizer15, 0, wxEXPAND, 5 );
	
	sliceDraw = new SliceDraw( this, wxID_ANY, wxDefaultPosition, wxSize( -1,50 ), wxTAB_TRAVERSAL );
	sliceDraw->SetMinSize( wxSize( -1,50 ) );
	sliceDraw->SetMaxSize( wxSize( -1,50 ) );
	
	bSizer8->Add( sliceDraw, 0, wxEXPAND|wxALL, 5 );
	
	m_staticline15 = new wxStaticLine( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLI_HORIZONTAL );
	bSizer8->Add( m_staticline15, 0, wxEXPAND | wxALL, 5 );
	
	m_staticText84 = new wxStaticText( this, wxID_ANY, wxT("Animation"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText84->Wrap( -1 );
	bSizer8->Add( m_staticText84, 0, wxALL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	wxFlexGridSizer* fgSizer7;
	fgSizer7 = new wxFlexGridSizer( 2, 3, 0, 0 );
	fgSizer7->AddGrowableCol( 1 );
	fgSizer7->SetFlexibleDirection( wxBOTH );
	fgSizer7->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	m_staticText85 = new wxStaticText( this, wxID_ANY, wxT("Forward (s)"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText85->Wrap( -1 );
	fgSizer7->Add( m_staticText85, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT, 5 );
	
	forwardSlider = new wxSlider( this, wxID_ANY, 0, 0, 100, wxDefaultPosition, wxDefaultSize, wxSL_HORIZONTAL );
	forwardSlider->SetToolTip( wxT("Forward in seconds is bounded by the time slice.") );
	
	fgSizer7->Add( forwardSlider, 0, wxALL|wxEXPAND, 5 );
	
	forward = new wxStaticText( this, wxID_ANY, wxT("1"), wxDefaultPosition, wxDefaultSize, 0 );
	forward->Wrap( -1 );
	forward->SetMinSize( wxSize( 40,-1 ) );
	
	fgSizer7->Add( forward, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT, 5 );
	
	m_staticText87 = new wxStaticText( this, wxID_ANY, wxT("Frequency (s)"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText87->Wrap( -1 );
	fgSizer7->Add( m_staticText87, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT, 5 );
	
	frequencySlider = new wxSlider( this, wxID_ANY, 0, 0, 100, wxDefaultPosition, wxDefaultSize, wxSL_HORIZONTAL );
	frequencySlider->SetToolTip( wxT("Frequency is a value between 0.001 and 4 seconds.") );
	
	fgSizer7->Add( frequencySlider, 0, wxALL|wxEXPAND|wxALIGN_CENTER_VERTICAL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	frequency = new wxStaticText( this, wxID_ANY, wxT("0.001"), wxDefaultPosition, wxDefaultSize, 0 );
	frequency->Wrap( -1 );
	frequency->SetMinSize( wxSize( 40,-1 ) );
	
	fgSizer7->Add( frequency, 0, wxALL|wxALIGN_RIGHT, 5 );
	
	bSizer8->Add( fgSizer7, 0, wxEXPAND, 5 );
	
	wxBoxSizer* bSizer25;
	bSizer25 = new wxBoxSizer( wxHORIZONTAL );
	
	playButton = new wxButton( this, wxID_ANY, wxT("Play"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer25->Add( playButton, 0, wxALL, 5 );
	
	pauseButton = new wxButton( this, wxID_ANY, wxT("Pause"), wxDefaultPosition, wxDefaultSize, 0 );
	bSizer25->Add( pauseButton, 0, wxALL, 5 );
	
	bSizer8->Add( bSizer25, 0, wxALIGN_CENTER_HORIZONTAL, 5 );
	
	this->SetSizer( bSizer8 );
	this->Layout();
	
	// Connect Events
	startSlider->Connect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Connect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Connect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Connect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Connect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Connect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Connect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Connect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Connect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Connect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	m_button4->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::apply ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Connect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Connect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	playButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::play ), NULL, this );
	pauseButton->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::pause ), NULL, this );
}

TimeIntervalWindowAuto::~TimeIntervalWindowAuto()
{
	// Disconnect Events
	startSlider->Disconnect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Disconnect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Disconnect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Disconnect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Disconnect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Disconnect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Disconnect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Disconnect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	startSlider->Disconnect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	sizeSlider->Disconnect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::sliderChanged ), NULL, this );
	m_button4->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::apply ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	forwardSlider->Disconnect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_TOP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_BOTTOM, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_LINEUP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_LINEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_PAGEUP, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_PAGEDOWN, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_THUMBTRACK, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_THUMBRELEASE, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	frequencySlider->Disconnect( wxEVT_SCROLL_CHANGED, wxScrollEventHandler( TimeIntervalWindowAuto::animationSliderChanged ), NULL, this );
	playButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::play ), NULL, this );
	pauseButton->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( TimeIntervalWindowAuto::pause ), NULL, this );
}
