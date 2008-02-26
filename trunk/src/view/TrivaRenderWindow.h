#ifndef TRIVA_RENDER_WINDOW_H
#define TRIVA_RENDER_WINDOW_H

#include "wxOgreRenderWindow.h"

class TrivaRenderWindow : public wxOgreRenderWindow
{
public:
	TrivaRenderWindow();
	TrivaRenderWindow(wxWindow *parent, wxWindowID id,
			const wxPoint &pos = wxDefaultPosition,
			const wxSize &size = wxDefaultSize,
			long style = wxSUNKEN_BORDER,
			const wxValidator &validator = wxDefaultValidator);
	void OnKeyDownEvent(wxKeyEvent& evt);
};

#endif
