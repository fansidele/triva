#include "MarcoWindow.h"
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

MarcoWindow::MarcoWindow( wxWindow* parent )
:
MarcoWindowAuto( parent )
{
	draw->setWindow (this);
}

MarcoDraw *MarcoWindow::getDraw()
{
	return draw;
}

void MarcoWindow::setStatusMessage (wxString message)
{
	statusBar->SetStatusText (message);
}
