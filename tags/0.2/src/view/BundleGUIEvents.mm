#include "BundleGUIEvents.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

void BundleGUIEvents::setBundleName (std::string n)
{
	bundleName = n; 
	this->SetTitle(wxT("dimvisual-kaapi.bundle"));
}

void BundleGUIEvents::traceFilePicker( wxCommandEvent& event )
{
	wxFileDialog *f = new wxFileDialog (NULL, wxT("Choose multiple files"), 
wxT(""), wxT(""), wxT("*.trc"), wxOPEN|wxMULTIPLE|wxFILE_MUST_EXIST,
wxDefaultPosition);

	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	NSString *v = [d stringForKey:@"LastOpenDirectory"];
	if (v != nil){
		wxString dir = NSSTRINGtoWXSTRING(v);
		f->SetPath (dir);
	}

	if (f->ShowModal() == wxID_OK){
		wxArrayString files;
		f->GetPaths (files);
		traceFileOpened->InsertItems(files,0);
		activateButton->Enable();

		wxString path = f->GetPath().BeforeLast('/').Append('/');

		[d setObject: WXSTRINGtoNSSTRING(path) forKey: @"LastOpenDirectory"];
		[d synchronize];		
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

	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	NSString *v = [d stringForKey:@"LastOpenDirectory"];
	if (v != nil){
		wxString dir = NSSTRINGtoWXSTRING(v);
		f->SetPath (dir);
	}

	if (f->ShowModal() == wxID_OK){
		syncFileOpened->Insert(f->GetPath(),0);

		wxString path = f->GetPath().BeforeLast('/').Append('/');

		[d setObject:  WXSTRINGtoNSSTRING(path) forKey: @"LastOpenDirectory"];
		[d synchronize];		
	}
}

void BundleGUIEvents::removeSyncFile( wxCommandEvent& event )
{
	syncFileOpened->Clear();
}

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
		[ar addObject: WXSTRINGtoNSSTRING(s)];
	}
	[parameters setObject: ar forKey: @"files"];

	n = syncFileOpened->GetCount();
	if (n != 0){
		wxString s = syncFileOpened->GetString(0);
		[parameters setObject: WXSTRINGtoNSSTRING(s)
				forKey: @"sync"];
	}else{
		[parameters removeObjectForKey: @"sync"];
	}


	NSMutableSet *types = [NSMutableSet
setWithSet: [[conf objectForKey: @"parameters"] objectForKey:
@"type"]];
	wxString type = setupChoice->GetStringSelection();
	NSString *typestr = WXSTRINGtoNSSTRING(type);
	[types intersectSet: [NSSet setWithObject: WXSTRINGtoNSSTRING(type)]];
	[parameters setObject: types forKey: @"type"];	

	NSMutableDictionary *eventsdir = this->getConfigureSetupTab();
	[parameters setObject: eventsdir forKey: @"events"];
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
		setupCheckList->Disable();
		std::cout << "controller = " << controller << std::endl;
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

void BundleGUIEvents::setReader (ProtoReader *r)
{
	reader = r;

	this->configureSetupTab();
}

void BundleGUIEvents::configureSetupTab()
{
	NSMutableDictionary *conf = [NSMutableDictionary
dictionaryWithDictionary: [reader
getConfigurationOptionsFromDIMVisualBundle: @"dimvisual-kaapi.bundle"]];

	NSMutableDictionary *events = [NSMutableDictionary
dictionaryWithDictionary: [[conf objectForKey: @"parameters"] objectForKey:
@"events"]];

	NSMutableSet *types = [NSMutableSet setWithSet: [[conf objectForKey:
@"parameters"] objectForKey: @"type"]];

	NSLog (@"conf = %@", conf);
	
	NSArray *ar = [events allKeys];
	wxArrayString wsar;
	unsigned int i;
	for (i=0; i < [ar count]; i++){
		wsar.Add(NSSTRINGtoWXSTRING([ar objectAtIndex: i]));
	}
	setupCheckList->InsertItems (wsar,0);
	for (i=0; i < setupCheckList->GetCount(); i++){
		setupCheckList->Check(i,true);
	}

	NSArray *ar2 = [types allObjects];
	NSLog (@"types = %@", types);
	for (i=0; i < [ar2 count]; i++){
		setupChoice->Insert(NSSTRINGtoWXSTRING([ar2 objectAtIndex: i]),i);
	}
	setupChoice->Select(1);
}

NSMutableDictionary *BundleGUIEvents::getConfigureSetupTab()
{
	unsigned int i;
	NSMutableDictionary *conf = [NSMutableDictionary dictionaryWithDictionary: [reader getConfigurationOptionsFromDIMVisualBundle: @"dimvisual-kaapi.bundle"]];
	NSMutableSet *types = [NSMutableSet
setWithSet: [[conf objectForKey: @"parameters"] objectForKey:
@"type"]];

	NSMutableDictionary *events = [NSMutableDictionary
dictionaryWithDictionary: [[conf objectForKey: @"parameters"] objectForKey:
@"events"]];

	for (i=0; i < setupCheckList->GetCount(); i++){
		if (!setupCheckList->IsChecked(i)){
			wxString notc = setupCheckList->GetString(i);
			[events removeObjectForKey: WXSTRINGtoNSSTRING(notc)];
		}
	}
	return events;
}
