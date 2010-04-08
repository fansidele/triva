#ifndef __MADraw__
#define __MADraw__

#include <Foundation/Foundation.h>
#include "wx/wx.h"
#include <General/PajeFilter.h>
#include "MAWindow.h"
#include "MALayout.h"

class MAWindow;

class MADraw : public wxControl
{
	DECLARE_CLASS (MADraw)
	DECLARE_EVENT_TABLE ()
	DECLARE_NO_COPY_CLASS (MADraw)

private:
	MAWindow *window;
	id filter;

public:
	MADraw (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
	void setController (id contr) { filter = contr; };
	void setWindow (MAWindow *w) { window = w; };

protected:
	/* wxWidgets callbacks */
	virtual void OnPaint(wxPaintEvent& evt);
	virtual void OnMouseEvent(wxMouseEvent& evt);
	virtual void OnKeyDownEvent(wxKeyEvent& evt);
	virtual void OnSize(wxSizeEvent& evt);
//	virtual void OnMouseCapureLost(wxMouseCaptureLostEvent& evt);
//	virtual void OnCharEvent(wxKeyEvent& evt);
//	virtual void OnKeyUpEvent(wxKeyEvent& evt);
//	virtual void OnRenderTimer(wxTimerEvent& evt);

	wxColour findColorForEntity (id entity);
	void drawCPUandThreads (wxDC &dc);
	void drawMemory (wxDC &dc);
	void drawRect (wxString name, MARect *rect, wxDC &dc);

};

#endif
