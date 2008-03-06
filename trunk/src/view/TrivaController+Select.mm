#include "TrivaController.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

void TrivaController::selectObjectIdentifier (std::string name)
{
/*
	if (view){
		NSString *identifier;
		identifier = [NSString stringWithFormat: @"%s", name.c_str()];
		[view selectObjectIdentifier: identifier];
		XState *s = (XState *)[view objectWithIdentifier: identifier];
		NSMutableString *info = [NSMutableString string];
		[info appendString: [NSString stringWithFormat: @"%@ - %@,%@",
[s type], [s start], [s end]]];
		statusBar->SetStatusText (NSSTRINGtoWXSTRING(info));
	}
*/
}

void TrivaController::unselectObjectIdentifier (std::string name)
{
/*
	if (view){
		[view unselectObjectIdentifier: [NSString stringWithFormat: @"%s",
name.c_str()]];
	}
*/
}
