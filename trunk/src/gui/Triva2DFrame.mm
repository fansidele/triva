#include "Triva2DFrame.h"
#include "gui/TrivaController.h"
#include "time-slice/TimeSlice.h"

#if defined(__WXGTK__)
   // NOTE: Find the GTK install config with `pkg-config --cflags gtk+-2.0`
   #include "gtk/gtk.h"
   #include "gdk/gdk.h"
   #include "gdk/gdkx.h"
   #include "wx/gtk/win_gtk.h"
   #include "GL/glx.h"
#endif

IMPLEMENT_CLASS( Triva2DFrame, wxControl )

BEGIN_EVENT_TABLE( Triva2DFrame, wxControl )
	EVT_SIZE( Triva2DFrame::OnSize )
	EVT_MOUSE_EVENTS( Triva2DFrame::OnMouseEvent )
	EVT_CHAR( Triva2DFrame::OnCharEvent )
	EVT_KEY_DOWN( Triva2DFrame::OnKeyDownEvent )
	EVT_KEY_UP( Triva2DFrame::OnKeyUpEvent )
	EVT_PAINT( Triva2DFrame::OnPaint )
	EVT_MOUSE_CAPTURE_LOST( Triva2DFrame::OnMouseCapureLost )
END_EVENT_TABLE ()

Triva2DFrame::Triva2DFrame()
{
	Init();
}

Triva2DFrame::Triva2DFrame (wxWindow *parent, wxWindowID id,
                const wxPoint &pos,
                const wxSize &size,
                long style,
                const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);
}

bool Triva2DFrame::Create(wxWindow *parent, wxWindowID id,
                const wxPoint &pos,
                const wxSize &size,
                long style,
                const wxValidator &validator)
{
	if (!wxControl::Create(parent, id, pos, size, style, validator)){
		return false;
	}
	return true;
}


Triva2DFrame::~Triva2DFrame()
{
}

void Triva2DFrame::Init()
{
}

void Triva2DFrame::Update()
{
}

void Triva2DFrame::OnSize(wxSizeEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnMouseEvent(wxMouseEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnMouseCapureLost(wxMouseCaptureLostEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnCharEvent(wxKeyEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnKeyDownEvent(wxKeyEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnKeyUpEvent(wxKeyEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnRenderTimer(wxTimerEvent& evt)
{}

void Triva2DFrame::OnPaint(wxPaintEvent& evt)
{
   // An instance of wxPaintDC must be created always in OnPaint event
   // (even if it's not used).
   wxPaintDC dc(this);

	wxCoord w, h;
	dc.GetSize(&w, &h);

	TimeSlice *filter = controller->getTimeSlice();
	Treemap *tree = [filter treemapWithWidth: w andHeight: h];

   // FIXME: Thread-safty!
   Update();
}
