#include "TrivaColorWindowEvents.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);

/*
void TrivaColorWindowEvents::removeTraceFile( wxCommandEvent& event )
{
	wxArrayInt sel;
	while(traceFileOpened->GetSelections(sel) != 0){
		traceFileOpened->Delete(sel[0]);
	}
	if (traceFileOpened->GetCount() == 0){
		activateButton->Disable();
	}
}
*/

void TrivaColorWindowEvents::addMaterialOption (wxString materialName)
{
	stateCombo->Insert (materialName, stateCombo->GetCount());
}

TrivaColorWindowEvents::TrivaColorWindowEvents( wxWindow* parent, wxWindowID ide, 
const wxString& title, const wxPoint& pos, const wxSize& size, 
long style ) : 
TrivaColorWindow( parent, ide, 
title, pos, size, 
style )
{
}

