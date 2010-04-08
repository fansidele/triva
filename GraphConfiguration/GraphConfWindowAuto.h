///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __GraphConfWindowAuto__
#define __GraphConfWindowAuto__

#include <wx/string.h>
#include <wx/textctrl.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/filepicker.h>
#include <wx/button.h>
#include <wx/sizer.h>
#include <wx/frame.h>
#include <wx/aui/auibook.h>
#include <wx/stattext.h>
#include <wx/listbox.h>
#include <wx/statline.h>
#include <wx/panel.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class GraphConfWindowAuto
///////////////////////////////////////////////////////////////////////////////
class GraphConfWindowAuto : public wxFrame 
{
	private:
	
	protected:
		wxTextCtrl* configuration;
		wxFilePickerCtrl* m_filePicker1;
		wxButton* apply;
		
		// Virtual event handlers, overide them in your derived class
		virtual void loadFile( wxFileDirPickerEvent& event ){ event.Skip(); }
		virtual void applyCurrentConfiguration( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		GraphConfWindowAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva - Graph Configuration"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 335,346 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~GraphConfWindowAuto();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class GraphConfWindowAuto_Bak
///////////////////////////////////////////////////////////////////////////////
class GraphConfWindowAuto_Bak : public wxFrame 
{
	private:
	
	protected:
		wxAuiNotebook* panels;
		wxButton* newconf;
		wxButton* apply;
		
		// Virtual event handlers, overide them in your derived class
		virtual void addNewConfigurationPanel( wxCommandEvent& event ){ event.Skip(); }
		virtual void applyCurrentConfiguration( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		GraphConfWindowAuto_Bak( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva - Graph Configuration"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 335,600 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~GraphConfWindowAuto_Bak();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class GraphConfPanelAuto
///////////////////////////////////////////////////////////////////////////////
class GraphConfPanelAuto : public wxPanel 
{
	private:
	
	protected:
		wxStaticText* m_staticText20;
		wxStaticText* m_staticText13;
		wxListBox* containers;
		wxStaticText* m_staticText14;
		wxListBox* values;
		wxStaticLine* m_staticline2;
		wxStaticText* m_staticText15;
		wxStaticText* m_staticText16;
		wxTextCtrl* nodes;
		wxStaticText* m_staticText17;
		wxTextCtrl* nodeSize;
		wxStaticText* m_staticText18;
		wxTextCtrl* nodePosition;
		wxStaticText* m_staticText19;
		wxTextCtrl* nodeSeparation;
		wxStaticLine* m_staticline21;
		wxStaticText* m_staticText151;
		wxStaticText* m_staticText8;
		wxTextCtrl* edges;
		wxStaticText* m_staticText9;
		wxTextCtrl* edgeSize;
		wxStaticText* m_staticText11;
		wxTextCtrl* edgeSeparation;
	
	public:
		GraphConfPanelAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 326,492 ), long style = wxTAB_TRAVERSAL );
		~GraphConfPanelAuto();
	
};

#endif //__GraphConfWindowAuto__
