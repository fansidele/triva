#include "GraphConfWindow.h"
#include "GraphConfPanel.h"
#include <iostream>

wxString NSSTRINGtoWXSTRING (NSString *ns)
{
        if (ns == nil){
                return wxString();
        }
        return wxString::FromAscii ([ns cString]);
}

NSString *WXSTRINGtoNSSTRING (wxString wsa)
{
	int length = wsa.Length();
	char *sa = (char*)malloc(length+1*sizeof(char));
        snprintf (sa, length+1, "%S", wsa.c_str());
        NSString *ret = [NSString stringWithFormat:@"%s", sa];
	free (sa);
	return ret;
}

std::string WXSTRINGtoSTDSTRING (wxString wsa)
{
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return std::string(sa);
}

GraphConfWindow::GraphConfWindow ( wxWindow* parent )
:
GraphConfWindowAuto (parent)
{
	//TODO: get file string from defaults, put in configuration control
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *file = [defaults stringForKey: @"GraphConfigurationFile"];
	if (file){
		wxFileDirPickerEvent event;
		event.SetPath(NSSTRINGtoWXSTRING(file));
		this->loadFile (event);
	}
}

void GraphConfWindow::addNewConfigurationPanel( wxCommandEvent& event )
{
/*
	std::cout << __FUNCTION__ << std::endl;
	GraphConfPanel *panel = new GraphConfPanel (this, filter);
	panel->setController (filter);
	std::cout << panel << std::endl;
	panels->AddPage(panel, wxT("(noname)*"));
*/
}

void GraphConfWindow::applyCurrentConfiguration( wxCommandEvent& event )
{
	NSString *conf = WXSTRINGtoNSSTRING (configuration->GetValue());
	[filter setConfiguration: [conf propertyList]];
}

void GraphConfWindow::loadFile( wxFileDirPickerEvent& event )
{
	wxString path = event.GetPath();
	NSString *file = WXSTRINGtoNSSTRING(path);
	NSString *contents = [NSString stringWithContentsOfFile: file];
	configuration->SetValue (NSSTRINGtoWXSTRING(contents));

	//TODO: save file string in defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: file forKey: @"GraphConfigurationFile"];
	[defaults synchronize];
}
