#include "GUI_CombinedCounter.h"

extern std::string WXSTRINGtoSTDSTRING (wxString wsa);
extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

void GUI_CombinedCounter::addStateType ( wxCommandEvent& event )
{
	wxString selected = stateTypeListValues->GetStringSelection();
	wxString text = stateTypeWeight->GetValue();

	combinedConfiguration->AppendText (selected);
	combinedConfiguration->AppendText (wxT("("));
	combinedConfiguration->AppendText (text);
	combinedConfiguration->AppendText (wxT(") "));

	NSString *value = WXSTRINGtoNSSTRING (selected);
	NSString *weight = WXSTRINGtoNSSTRING (text);
	
	NSMutableDictionary *stateConfig;
	stateConfig = [configuration objectForKey: @"State"];
	if (stateConfig == nil){
		stateConfig = [NSMutableDictionary dictionary];
		[configuration setObject: stateConfig forKey: @"State"];
	}
	[stateConfig setObject: weight forKey: value];
}

void GUI_CombinedCounter::clear ( wxCommandEvent& event )
{
	this->reconfigure();
}

void GUI_CombinedCounter::apply ( wxCommandEvent& event )
{
	ProtoView *view = controller->getView();
	[view setCombinedCounterConfiguration: configuration];
}

void GUI_CombinedCounter::close( wxCommandEvent& event )
{
	this->Hide();
}

GUI_CombinedCounter::GUI_CombinedCounter( wxWindow* parent, wxWindowID ide,
const wxString& title, const wxPoint& pos, const wxSize& size,
long style ) :
AutoGUI_CombinedCounter ( parent, ide,
title, pos, size,
style )
{
	TrivaController *c = (TrivaController *)parent;
	configuration = nil;
}

void GUI_CombinedCounter::onClose( wxCloseEvent& event )
{
	if (!event.CanVeto()){
		Close();
	}else{
		Hide();
	}
}

void GUI_CombinedCounter::reconfigure ()
{
	stateTypeListValues->Clear();
	combinedConfiguration->Clear();

	if (configuration != nil){
		[configuration release];
	}
	configuration = [[NSMutableDictionary alloc] init];

	ProtoView *view = controller->getView();
	PajeEntityType *et;
	NSEnumerator *en;

	en = [[view allEntityTypes] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if (![view isContainerEntityType:et] &&
				[et isKindOfClass: [PajeStateType class]]) {
			NSEnumerator *en2 = [[view allValuesForEntityType: et]
						objectEnumerator];
			id val;
			while ((val = [en2 nextObject]) != nil){
				NSString *entry;
				entry = [NSString stringWithFormat: @"%@", val];
				int pos = stateTypeListValues->GetCount();
				stateTypeListValues->Insert(
					NSSTRINGtoWXSTRING(entry), pos);
			}
		}
	}
}
