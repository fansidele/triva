#ifndef __DotDraw__
#define __DotDraw__

#include <Foundation/Foundation.h>
#include <gvc.h>
#include "wx/wx.h"
#include "Dot.h"
#include <General/PajeFilter.h>
#include <limits.h>
#include <float.h>

#include "DotWindow.h"

class DotWindow;

class DotDraw : public wxControl
{
	DECLARE_CLASS (DotDraw)
	DECLARE_EVENT_TABLE ()
	DECLARE_NO_COPY_CLASS (DotDraw)

private: /* draw platform related */
	NSArray *hosts;
	NSArray *routes;
	graph_t *resGraph;
	GVC_t *gvc;

	float minBandwidth, maxBandwidth;
	float minPower, maxPower;

private:
	DotWindow *window;
	id filter;

public:
	DotDraw (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
	void setController (id contr) { filter = contr; };
	void setWindow (DotWindow *w) { window = w; };
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
	void highlightDotNode (long x, long y);
	void unhighlightDotNode (wxDC &dc);

	void drawHighlightDotNode (id node, wxDC &dc);
	void drawDotNode (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	void drawDotNode2 (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	wxColour findColorForNode (id treemap);
	void drawDot (id treemap, wxDC &dc);
*/
};

#endif
