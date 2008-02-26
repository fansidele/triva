#ifndef __BundleGUIEvents__
#define __BundleGUIEvents__

#include "TRIVAGUI.h"
#include "core/TrivaController.h"
#include <wx/wxprec.h>
#include <wx/wx.h>
#include "reader/ProtoReader.h"
#include <vector>

class TrivaController;

class BundleGUIEvents : public BundleGUI
{
private:
	TrivaController *controller;
	ProtoReader *reader;
	std::string bundleName;
	std::streambuf *sbOld;

protected:
	// Handlers for BundleGUI events.
	void activate( wxCommandEvent& event );
        void traceFilePicker( wxCommandEvent& event );
        void removeTraceFile( wxCommandEvent& event );
        void syncFilePicker( wxCommandEvent& event );
        void removeSyncFile( wxCommandEvent& event );

public:
	void setReader (ProtoReader *r) { reader = r; };
	void setController (TrivaController *t) { controller = t; };
	void setBundleName (std::string n);
	/** Constructor */
	BundleGUIEvents( wxWindow* parent, wxWindowID id = wxID_ANY, const wxString& title = wxEmptyString, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,300 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );

};

#endif // __BundleGUIEvents__