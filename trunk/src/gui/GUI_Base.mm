#include "GUI_Base.h"

extern std::string WXSTRINGtoSTDSTRING (wxString wsa);
extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

void GUI_Base::choice ( wxCommandEvent& event )
{
	std::string option;

	option = WXSTRINGtoSTDSTRING(base_type->GetStringSelection());
	if (option.compare ("Application Graph") == 0){
		configuration_file->Disable();
		width->Disable();
		height->Disable();
	}else if (option.compare ("Resources Squarified Treemap") == 0){
		configuration_file->Enable();
		width->Enable();
		height->Enable();
	}else{
		// do nothing
	}
	status->SetStatusText (NSSTRINGtoWXSTRING(@""));
}

void GUI_Base::apply ( wxCommandEvent& event )
{
	std::string option;
	ProtoView *view = controller->getView();

	option = WXSTRINGtoSTDSTRING(base_type->GetStringSelection());
	if (option.compare ("Application Graph") == 0){
		[view applicationGraph];
		status->SetStatusText (NSSTRINGtoWXSTRING(@"Application Graph OK"));
	}else if (option.compare ("Resources Squarified Treemap") == 0){
		wxString path = configuration_file->GetLabel();
		NSString *file = WXSTRINGtoNSSTRING (path);

		float w = atof(WXSTRINGtoSTDSTRING(width->GetValue()).c_str());
		float h = atof(WXSTRINGtoSTDSTRING(height->GetValue()).c_str());
		BOOL x = [view squarifiedTreemapWithFile: file
			andWidth: w andHeight: h];
        
		NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
		[d setObject: [NSString stringWithFormat: @"%.0f", w]
			forKey: @"WidthTreemapBaseConfiguration"];
		[d setObject: [NSString stringWithFormat: @"%.0f", h]
			forKey: @"HeightTreemapBaseConfiguration"];
		[d synchronize];

		if (x){
			status->SetStatusText (NSSTRINGtoWXSTRING(@"Dynamic Squarified Treemap OK"));
		}else{
			status->SetStatusText (NSSTRINGtoWXSTRING(@"error, check file format"));
		}
	}
}

void GUI_Base::load( wxCommandEvent& event )
{
        wxFileDialog *f;
        f = new wxFileDialog (NULL, wxT("Choose one file"),
                                wxT(""), wxT(""), wxT("*.plist"),
                                wxOPEN|wxFILE_MUST_EXIST, wxDefaultPosition);

        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *v = [d stringForKey:@"LastOpenBaseDirectory"];
        if (v != nil){
                wxString dir = NSSTRINGtoWXSTRING(v);
                f->SetPath (dir);
        }

        if (f->ShowModal() == wxID_OK){
                wxString path = f->GetPath();
		configuration_file->SetLabel (path);

		char sa[100];
		snprintf (sa, 100, "%S", path.c_str());

		[d setObject: [NSString stringWithFormat:@"%s", sa] 
			forKey: @"LastOpenBaseDirectory"];
		[d synchronize];
	}
}

void GUI_Base::close( wxCommandEvent& event )
{
	this->Hide();
}

GUI_Base::GUI_Base( wxWindow* parent, wxWindowID ide,
const wxString& title, const wxPoint& pos, const wxSize& size,
long style ) :
AutoGUI_Base ( parent, ide,
title, pos, size,
style )
{
	TrivaController *c = (TrivaController *)parent;
	ProtoView *view = c->getView();
	[view applicationGraph];

	base_type->SetStringSelection(NSSTRINGtoWXSTRING(@"Application Graph"));
	wxCommandEvent e;
	this->choice (e);
        
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *w = [d stringForKey:@"WidthTreemapBaseConfiguration"];
        if (w != nil){
                wxString val = NSSTRINGtoWXSTRING(w);
                width->SetValue (val);
        }
        NSString *h = [d stringForKey:@"HeightTreemapBaseConfiguration"];
        if (h != nil){
                wxString val = NSSTRINGtoWXSTRING(h);
                height->SetValue (val);
        }
}
