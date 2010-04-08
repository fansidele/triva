#ifndef __SimGridDraw__
#define __SimGridDraw__

#include <Foundation/Foundation.h>
#include <gvc.h>
#include "wx/wx.h"
#include "SimGrid.h"
#include <General/PajeFilter.h>
#include <limits.h>
#include <float.h>

#include "SimGridWindow.h"

class SimGridWindow;

class SimGridDraw : public wxControl
{
	DECLARE_CLASS (SimGridDraw)
	DECLARE_EVENT_TABLE ()
	DECLARE_NO_COPY_CLASS (SimGridDraw)

private: /* draw related */
	NSArray *hosts;
	NSArray *links;
	graph_t *resGraph;
	GVC_t *gvc;

	float minBandwidth, maxBandwidth;
	float minPower, maxPower;

private:
	SimGridWindow *window;
	id filter;

public:
	SimGridDraw (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
	void setController (id contr) { filter = contr; };
	void setWindow (SimGridWindow *w) { window = w; };
	void definePlatform ();

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
	void highlightSimGridNode (long x, long y);
	void unhighlightSimGridNode (wxDC &dc);

	void drawHighlightSimGridNode (id node, wxDC &dc);
	void drawSimGridNode (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	void drawSimGridNode2 (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	wxColour findColorForNode (id treemap);
	void drawSimGrid (id treemap, wxDC &dc);
*/
	void drawPlatform (wxDC &dc);
	void drawPlatformState (wxDC &dc); //host and link utilization
	void highlightHost (id host);
	id findHostAt (int mx, int my);
};

#endif
