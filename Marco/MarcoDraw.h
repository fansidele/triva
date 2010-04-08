#ifndef __MarcoDraw__
#define __MarcoDraw__

#include <Foundation/Foundation.h>
#include <gvc.h>
#include "wx/wx.h"
#include "Marco.h"
#include <General/PajeFilter.h>
#include <limits.h>
#include <float.h>

#include "MarcoWindow.h"

class MarcoWindow;

class MarcoDraw : public wxControl
{
	DECLARE_CLASS (MarcoDraw)
	DECLARE_EVENT_TABLE ()
	DECLARE_NO_COPY_CLASS (MarcoDraw)

private: /* draw platform related */
	NSArray *hosts;
	NSArray *routes;
	graph_t *resGraph;
	GVC_t *gvc;

	float minBandwidth, maxBandwidth;
	float minPower, maxPower;

private:
	MarcoWindow *window;
	id filter;

public:
	MarcoDraw (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
	void setController (id contr) { filter = contr; };
	void setWindow (MarcoWindow *w) { window = w; };
	void recreateResourcesGraph ();
	void drawPlatform (wxDC &dc);
	void drawApplication (wxDC &dc);

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

	/* highlight related methods */
/*
	void highlightMarcoNode (long x, long y);
	void unhighlightMarcoNode (wxDC &dc);

	void drawHighlightMarcoNode (id node, wxDC &dc);
	void drawMarcoNode (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	void drawMarcoNode2 (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	wxColour findColorForNode (id treemap);
	void drawMarco (id treemap, wxDC &dc);
*/
};

#endif
