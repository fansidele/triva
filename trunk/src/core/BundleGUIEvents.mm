#include "BundleGUIEvents.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

void BundleGUIEvents::setBundleName (std::string n)
{
	bundleName = n; 
	this->SetTitle(wxT("dimvisual-kaapi.bundle"));
/*

	root = treeConf->AddRoot (wxT("root"));
	files = treeConf->AppendItem (root, wxT("files"));
	sync = treeConf->AppendItem (root, wxT("sync"));

	[[NSUserDefaults standardUserDefaults] synchronize];
	NSString *str = [[NSUserDefaults standardUserDefaults]
		stringForKey:@"LastTraceDirectory"];
	NSLog (@"retomando str = %@", str);
	if (str){
		wxString to_format;
		to_format.Printf(wxT("%s"), [str cString]);
		to_format = wxString::Format(wxT("%s"), [str cString]);
//		std::cout << "# " << to_format.mb_str() << std::endl;
//		traceDir->ExpandPath (to_format);
	}
*/
}

void BundleGUIEvents::traceFilePicker( wxCommandEvent& event )
{
	wxFileDialog *f = new wxFileDialog (NULL, wxT("Choose multiple files"), 
wxT(""), wxT(""), wxT("*.trc"), wxOPEN|wxMULTIPLE|wxFILE_MUST_EXIST,
wxDefaultPosition);
	if (f->ShowModal() == wxID_OK){
		wxArrayString files;
		f->GetPaths (files);
		traceFileOpened->InsertItems(files,0);
		activateButton->Enable();
	}
}

void BundleGUIEvents::removeTraceFile( wxCommandEvent& event )
{
	wxArrayInt sel;
	while(traceFileOpened->GetSelections(sel) != 0){
		traceFileOpened->Delete(sel[0]);
	}
	if (traceFileOpened->GetCount() == 0){
		activateButton->Disable();
	}
}

void BundleGUIEvents::syncFilePicker( wxCommandEvent& event )
{
	wxFileDialog *f = new wxFileDialog (NULL, wxT("Choose one file"), 
wxT(""), wxT(""), wxT("*"), wxOPEN|wxFILE_MUST_EXIST, wxDefaultPosition);
	if (f->ShowModal() == wxID_OK){
		syncFileOpened->Insert(f->GetPath(),0);
	}
}

void BundleGUIEvents::removeSyncFile( wxCommandEvent& event )
{
	syncFileOpened->Clear();
}


/*
void BundleGUIEvents::addTraceFile( wxCommandEvent& event )
{
	wxString file = traceDir->GetFilePath();
	if (file != wxString()){
		treeConf->AppendItem (files, file);
	}

	wxString s = traceDir->GetPath();
	char sa[100];
	snprintf (sa, 100, "%S", s.c_str());
//
	NSString *str = [NSString stringWithFormat: @"%s", sa];
	NSLog (@"str = %@", str);
	[[NSUserDefaults standardUserDefaults] setObject:str forKey:@"LastTraceDirectory"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

void BundleGUIEvents::setSyncFile( wxCommandEvent& event )
{
	wxString file = traceDir->GetFilePath();
	if (file != wxString()){
		treeConf->DeleteChildren(sync);
		treeConf->AppendItem (sync, file);
	}

	wxString s = traceDir->GetPath();
	char sa[100];
	snprintf (sa, 100, "%S", s.c_str());
//
	NSString *str = [NSString stringWithFormat: @"%s", sa];
	NSLog (@"str = %@", str);
	[[NSUserDefaults standardUserDefaults] setObject:str forKey:@"LastTraceDirectory"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
*/

void BundleGUIEvents::activate( wxCommandEvent& event )
{
	NSMutableDictionary *conf = [NSMutableDictionary
dictionaryWithDictionary: [reader
getConfigurationOptionsFromDIMVisualBundle: @"dimvisual-kaapi.bundle"]];

	NSMutableDictionary *parameters = [NSMutableDictionary
dictionaryWithDictionary: [conf objectForKey: @"parameters"]];

	NSMutableArray *ar = [[NSMutableArray alloc] init];

	int i, n = traceFileOpened->GetCount();
	if (n == 0){
		wxMessageDialog *dial = new wxMessageDialog(NULL, wxT("No trace files defined"), wxT("Trace files"), wxOK | wxICON_EXCLAMATION);
		dial->ShowModal();
		return;
	}
	for (i = 0; i < n; i++){
		wxString s = traceFileOpened->GetString(i);
		char sa[100];
		snprintf (sa, 100, "%S", s.c_str());
		[ar addObject: [NSString stringWithFormat:@"%s", sa]];
	}
	[parameters setObject: ar forKey: @"files"];

	n = syncFileOpened->GetCount();
	if (n != 0){
		wxString s = syncFileOpened->GetString(0);
		char sa[100];
		snprintf (sa, 100, "%S", s.c_str());
		[parameters setObject: [NSString stringWithFormat:@"%s", sa]
				forKey: @"sync"];
	}else{
		[parameters removeObjectForKey: @"sync"];
	}
NS_DURING
	[conf setObject: parameters forKey: @"parameters"];
	if(![reader setConfiguration: conf forDIMVisualBundle:
@"dimvisual-kaapi.bundle"]){
		 wxMessageDialog *dial = new wxMessageDialog(NULL, 
    wxT("Error configuring bundle"), wxT("Error"), wxOK | wxICON_ERROR);
 dial->ShowModal();
	}else{
		/* */
		statusText->SetValue(wxT("OK"));
		activateButton->Disable();
		selectSyncButton->Disable();
		selectTraceButton->Disable();
		removeSyncFileButton->Disable();
		removeTraceFileButton->Disable();
		std::cout.rdbuf(sbOld);	
		controller->oneBundleConfigured();
	

	}
NS_HANDLER
	NSLog (@"Exception = %@", localException);
	wxString m = NSSTRINGtoWXSTRING ([localException reason]);
	wxString n = NSSTRINGtoWXSTRING ([localException name]);
	wxMessageDialog *dial = new wxMessageDialog(NULL, m, n, wxOK | wxICON_ERROR);
	dial->ShowModal();
NS_ENDHANDLER


}

BundleGUIEvents::BundleGUIEvents( wxWindow* parent, wxWindowID ide, 
const wxString& title, const wxPoint& pos, const wxSize& size, 
long style ) : 
BundleGUI( parent, ide, 
title, pos, size, 
style )
{
	activateButton->Disable();
}
