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

void TrivaColorWindowEvents::setMaterialToBeChanged (wxString materialName)
{
	std::cout << materialName.ToAscii() << std::endl;
	stateName->SetValue (materialName);//, stateCombo->GetCount());
}

void TrivaColorWindowEvents::setColorToBeChanged (wxColor color)
{
	std::cout << "setting color to: " << color.Red() << std::endl;
	colorPicker->SetColour(color);
}


void TrivaColorWindowEvents::colorChanged( wxColourPickerEvent& event )
{
//	if (!stateName->GetValue().IsEmpty())
//		return;
	wxColour c = colorPicker->GetColour();
	ProtoView *view = controller->getView();
	DrawManager *m = [view drawManager];
	std::string str = std::string (stateName->GetValue().ToAscii());
	Ogre::ColourValue og = controller->convertWxColor (c);
	m->setMaterialColor (str, og);
}

TrivaColorWindowEvents::TrivaColorWindowEvents( wxWindow* parent, wxWindowID ide, 
const wxString& title, const wxPoint& pos, const wxSize& size, 
long style ) : 
TrivaColorWindow( parent, ide, 
title, pos, size, 
style )
{
}

