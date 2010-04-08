///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec 29 2008)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __TypeFilterWindowAuto__
#define __TypeFilterWindowAuto__

#include <wx/treectrl.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/string.h>
#include <wx/checkbox.h>
#include <wx/checklst.h>
#include <wx/textctrl.h>
#include <wx/sizer.h>
#include <wx/frame.h>

///////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
/// Class TypeFilterWindowAuto
///////////////////////////////////////////////////////////////////////////////
class TypeFilterWindowAuto : public wxFrame 
{
	private:
	
	protected:
		wxTreeCtrl* typeHierarchyCrtl;
		wxCheckBox* mainCheckBox;
		wxCheckListBox* checkListBox;
		wxTextCtrl* regExpr;
		
		// Virtual event handlers, overide them in your derived class
		virtual void selectionChanged( wxTreeEvent& event ){ event.Skip(); }
		virtual void mainCheckBoxClicked( wxCommandEvent& event ){ event.Skip(); }
		virtual void checkListBoxClicked( wxCommandEvent& event ){ event.Skip(); }
		virtual void updateRegularExpr( wxCommandEvent& event ){ event.Skip(); }
		virtual void checkBasedOnRegularExpr( wxCommandEvent& event ){ event.Skip(); }
		
	
	public:
		TypeFilterWindowAuto( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("Triva - TypeFilter"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 490,508 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		~TypeFilterWindowAuto();
	
};

#endif //__TypeFilterWindowAuto__
