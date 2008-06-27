#include "TrivaController.h"
extern wxString NSSTRINGtoWXSTRING (NSString *ns);
/*
 * TrivaController+Base: all functions related to the GUI and especially
 * the menu "Base" of main window. All functions here communicates with
 * the "view" object which is an instance of ProtoView class.
 */

void TrivaController::squarifiedTreemap( wxCommandEvent& event )
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

		char sa[100];
		snprintf (sa, 100, "%S", path.c_str());

		[d setObject: [NSString stringWithFormat:@"%s", sa] forKey:
@"LastOpenBaseDirectory"];
		[d synchronize];

		if ([view squarifiedTreemapWithFile: 
			[NSString stringWithFormat: @"%s", sa]] == NO){
			NSLog (@"erro");
			treemap_squarified->Check (false);
		}else{
			//uncheck others
			treemap_original->Check (false);
			graph_resources->Check (false);
			graph_application->Check (false);
		}
	}
}

void TrivaController::originalTreemap( wxCommandEvent& event )
{
	event.Skip(); 
	//[view originalTreemapWithFile: (NSString *) file];
	treemap_original->Check (false);
}

void TrivaController::resourcesGraph( wxCommandEvent& event )
{
	event.Skip(); 
	//[view resourcesGraphWithFile: (NSString *) file];
	graph_resources->Check (false);
}

void TrivaController::applicationGraph( wxCommandEvent& event )
{
	//first, uncheck all others options
	treemap_squarified->Check (false);
	treemap_original->Check (false);
	graph_resources->Check (false);

	/* do something */
	[view applicationGraph];
}

void TrivaController::initializeBaseCategory ()
{
	//default is application graph
	treemap_squarified->Check (false);
	treemap_original->Check (false);
	graph_resources->Check (false);
	graph_application->Check (true);
	[view applicationGraph];
}

