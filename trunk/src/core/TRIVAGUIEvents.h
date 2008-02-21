#ifndef __TRIVAGUIEvents__
#define __TRIVAGUIEvents__

#include "TRIVAGUI.h"
#include <wx/wxprec.h>
#include <wx/wx.h>
#include "reader/ProtoReader.h"
//#include "core/ProtoController.h"
#include <vector>
#include "BundleGUIEvents.h"

DECLARE_EVENT_TYPE(wxEVT_MY_EVENT, -1)

BEGIN_DECLARE_EVENT_TYPES()
//	EVT_CUSTOM(trivaCHANGE_STATE, wxID_ANY, TRIVAGUIEvents::OnProcessCustom)
END_DECLARE_EVENT_TYPES()

class TRIVAGUIEvents : public TRIVAGUI
{
private:
	ProtoReader *reader;
//	ProtoController *controller;
	std::vector<BundleGUIEvents*> bundlesGUI;

protected:
	// Handlers for TRIVAGUI events.
	void loadbundle( wxCommandEvent& event );
	void exit( wxCommandEvent& event );
	void about( wxCommandEvent& event );
	void bundlesView ( wxCommandEvent& event );
	void playClicked( wxCommandEvent& event );

	//custom events (meus)
	void OnProcessCustom(wxCommandEvent& event) { std::cout << "aa" << std::endl; };
	
public:
	void setReader (ProtoReader *r) { reader = r; };
//	void setController (ProtoController *c) { controller = c; };
	
	/** Constructor */
	TRIVAGUIEvents( wxWindow* parent );
	TRIVAGUIEvents( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxT("TRIVA"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 600,480 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );

	DECLARE_EVENT_TABLE()
};




#endif // __TRIVAGUIEvents__
