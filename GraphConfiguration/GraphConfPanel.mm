#include "GraphConfPanel.h"
#include <iostream>

GraphConfPanel::GraphConfPanel( wxWindow* parent, id contr, wxWindowID id, const wxPoint& pos, const wxSize& size, long style )
:
GraphConfPanelAuto (parent, id, pos, size, style)
{
	//define filter
	filter = contr;

	//get container types
	NSEnumerator *en;
	PajeContainerType *type;
	en = [[filter getContainerTypes] objectEnumerator];
	while ((type = [en nextObject])){
		containers->Append(NSSTRINGtoWXSTRING([type name]));
	}

	en = [[filter getEntityTypes] objectEnumerator];
	while ((type = [en nextObject])){
		values->Append(NSSTRINGtoWXSTRING([type name]));
	}
}
