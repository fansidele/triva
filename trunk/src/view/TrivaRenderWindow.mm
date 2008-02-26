#include "TrivaRenderWindow.h"

TrivaRenderWindow::TrivaRenderWindow()
{

}

TrivaRenderWindow::TrivaRenderWindow(wxWindow *parent, wxWindowID id,
                        const wxPoint &pos,
                        const wxSize &size,
                        long style,
                        const wxValidator &validator) :
	wxOgreRenderWindow(parent,id,pos,size,style,validator)
{
}


void TrivaRenderWindow::OnKeyDownEvent(wxKeyEvent& evt)
{
	std::cout << __FILE__ << " : " << __FUNCTION__ << std::endl;
}