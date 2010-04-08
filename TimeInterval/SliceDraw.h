#ifndef __SliceDraw__
#define __SliceDraw__

#include <Foundation/Foundation.h>
#include "wx/wx.h"
#include <General/PajeFilter.h>
#include "TimeIntervalWindow.h"

class SliceDraw : public wxControl
{
	DECLARE_CLASS (SliceDraw)
	DECLARE_EVENT_TABLE ()
	DECLARE_NO_COPY_CLASS (SliceDraw)

private:
	TimeIntervalWindow *window;
	id filter;
	void drawTimeSliceText (wxDC &dc);

public:
	SliceDraw (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
	void setController (id contr) { filter = contr; };
	void setWindow (TimeIntervalWindow *w) { window = w; };

protected:
	/* wxWidgets callbacks */
	virtual void OnPaint(wxPaintEvent& evt);
	virtual void OnSize(wxSizeEvent& evt);
};

#endif
