#include "DotWindow.h"
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
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return [NSString stringWithFormat:@"%s", sa];
}

std::string WXSTRINGtoSTDSTRING (wxString wsa)
{
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return std::string(sa);
}

DotWindow::DotWindow( wxWindow* parent )
:
DotWindowAuto( parent )
{
	draw->setWindow (this);
}

DotDraw *DotWindow::getDraw()
{
	return draw;
}

void DotWindow::setStatusMessage (wxString message)
{
	statusBar->SetStatusText (message);
}
