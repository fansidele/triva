#include "GUI_Base.h"

extern std::string WXSTRINGtoSTDSTRING (wxString wsa);
extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

void GUI_Base::apply ( wxCommandEvent& event )
{
	std::string option;
	ProtoView *view = controller->getView();

	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	option = WXSTRINGtoSTDSTRING(base_type->GetPageText(base_type->GetSelection()));
	if (option.compare ("Application Graph") == 0){
		NSString *size = WXSTRINGtoNSSTRING(appgraph_size->GetValue());

		wxString algo = appgraph_choice1->GetStringSelection();
		NSString *algorithm = WXSTRINGtoNSSTRING (algo);

		BOOL x = [view applicationGraphWithSize: size andGraphvizAlgorithm: algorithm];
		if (x){
			status->SetStatusText (NSSTRINGtoWXSTRING(@"Application Graph OK"));
			[d setObject: [NSString stringWithFormat: @"%s", option.c_str()]
				forKey: @"BaseConfigurationOption"];
			[d setObject: size forKey: @"ApplicationGraphSize"];
		}else{
			status->SetStatusText (NSSTRINGtoWXSTRING(@"error in application graph configuration"));
		}
	}else if (option.compare ("Resources Squarified Treemap") == 0){
		wxString path = configuration_file->GetLabel();
		NSString *file = WXSTRINGtoNSSTRING (path);

		float w = atof(WXSTRINGtoSTDSTRING(width->GetValue()).c_str());
		float h = atof(WXSTRINGtoSTDSTRING(height->GetValue()).c_str());
		BOOL x = [view squarifiedTreemapWithFile: file
			andWidth: w andHeight: h];
        
		[d setObject: [NSString stringWithFormat: @"%.0f", w]
			forKey: @"WidthTreemapBaseConfiguration"];
		[d setObject: [NSString stringWithFormat: @"%.0f", h]
			forKey: @"HeightTreemapBaseConfiguration"];

		if (x){
			status->SetStatusText (NSSTRINGtoWXSTRING(@"Dynamic Squarified Treemap OK"));

			[d setObject: [NSString stringWithFormat: @"%s", option.c_str()]
				forKey: @"BaseConfigurationOption"];
		}else{
			status->SetStatusText (NSSTRINGtoWXSTRING(@"error, check file format"));
		}
	}else if (option.compare ("Resources Graph") == 0){
		wxString path = rg_configuration_file->GetLabel();
		NSString *file = WXSTRINGtoNSSTRING (path);

		wxString algo = rg_choice->GetStringSelection();
		NSString *algorithm = WXSTRINGtoNSSTRING (algo);

		NSString *size = WXSTRINGtoNSSTRING(rg_size->GetValue());

		[d setObject: algorithm forKey: @"LastGraphvizAlgorithm"];

		BOOL x = true;
		[view resourcesGraphWithFile: file
				andSize: size
				andGraphvizAlgorithm: algorithm];
		if (x){
			status->SetStatusText (NSSTRINGtoWXSTRING 
					(@"Resources Graph OK"));
			[d setObject: [NSString stringWithFormat: @"%s",
					option.c_str()]
				forKey: @"BaseConfigurationOption"];
		}else{
			status->SetStatusText (NSSTRINGtoWXSTRING(@"error, check file format"));
		}

	}
	[d synchronize];
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

	NSString *v = [d stringForKey:@"LastOpenBaseDirectory"];
	if (v != nil){
		wxString dir = NSSTRINGtoWXSTRING(v);
		configuration_file->SetLabel (dir);
	}

	NSString *o = [d stringForKey:@"BaseConfigurationOption"];
	if (o != nil){
		wxString opt = NSSTRINGtoWXSTRING(o);
		unsigned int i;
		for (i = 0; i < base_type->GetPageCount(); i++){
			if (opt == base_type->GetPageText(i)){
				base_type->SetSelection(i);
				break;
			}
		}
	}

	//resources graph
	o = [d stringForKey:@"LastOpenResourcesGraphBaseDirectory"];
	if (o != nil){
		wxString opt = NSSTRINGtoWXSTRING(o);
		rg_configuration_file->SetLabel (opt);
	}
	o = [d stringForKey:@"LastGraphvizAlgorithm"];
	if (o != nil){
		wxString opt = NSSTRINGtoWXSTRING(o);
		rg_choice->SetStringSelection (opt);
	}
}

void GUI_Base::onClose( wxCloseEvent& event )
{
	if (!event.CanVeto()){
		Close();
	}else{
		Hide();
	}
}

void GUI_Base::rg_load_graph( wxCommandEvent& event )
{
        wxFileDialog *f;
        f = new wxFileDialog (NULL, wxT("Choose one file"),
                                wxT(""), wxT(""), wxT("*.dot"),
                                wxOPEN|wxFILE_MUST_EXIST, wxDefaultPosition);

        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *v = [d stringForKey:@"LastOpenResourcesGraphBaseDirectory"];
        if (v != nil){
                wxString dir = NSSTRINGtoWXSTRING(v);
                f->SetPath (dir);
        }

        if (f->ShowModal() == wxID_OK){
                wxString path = f->GetPath();
		rg_configuration_file->SetLabel (path);

		char sa[100];
		snprintf (sa, 100, "%S", path.c_str());

		[d setObject: [NSString stringWithFormat:@"%s", sa] 
			forKey: @"LastOpenResourcesGraphBaseDirectory"];
		[d synchronize];
	}
}
