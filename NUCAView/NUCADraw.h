#ifndef __NUCADraw__
#define __NUCADraw__

#include <Foundation/Foundation.h>
#include <graphviz/gvc.h>
#include "wx/wx.h"
#include "NUCA.h"
#include <General/PajeFilter.h>
#include <limits.h>
#include <float.h>

#include "NUCAWindow.h"

class NUCAWindow;

class NUCADraw : public wxControl
{
	DECLARE_CLASS (NUCADraw)
	DECLARE_EVENT_TABLE ()
	DECLARE_NO_COPY_CLASS (NUCADraw)

private: /* draw platform related */
	NSArray *hosts;
	NSArray *routes;
	graph_t *resGraph;
	GVC_t *gvc;

	float minBandwidth, maxBandwidth;
	float minPower, maxPower;

private:
	NUCAWindow *window;
	id filter;

public:
	NUCADraw (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
	void setController (id contr) { filter = contr; };
	void setWindow (NUCAWindow *w) { window = w; };
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
	void highlightNUCANode (long x, long y);
	void unhighlightNUCANode (wxDC &dc);

	void drawHighlightNUCANode (id node, wxDC &dc);
	void drawNUCANode (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	void drawNUCANode2 (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	wxColour findColorForNode (id treemap);
	void drawNUCA (id treemap, wxDC &dc);
*/
};

#endif
