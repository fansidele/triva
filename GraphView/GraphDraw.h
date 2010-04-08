#ifndef __GraphDraw__
#define __GraphDraw__

#include <Foundation/Foundation.h>
#include <graphviz/gvc.h>
#include "wx/wx.h"
#include "Graph.h"
#include <General/PajeFilter.h>
#include <limits.h>
#include <float.h>
#include <cairo.h>

#include "GraphWindow.h"

class GraphWindow;

class GraphDraw : public wxControl
{
	DECLARE_CLASS (GraphDraw)
	DECLARE_EVENT_TABLE ()
	DECLARE_NO_COPY_CLASS (GraphDraw)

private:
	GraphWindow *window;
	TrivaFilter *filter;

public:
	GraphDraw (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
	void setController (TrivaFilter *contr) { filter = contr; };
	void setWindow (GraphWindow *w) { window = w; };

private:
	/* drawing functions */
	void drawNode (cairo_t *cr, TrivaGraphNode *node);
	void drawEdge (cairo_t *cr, TrivaGraphEdge *edge);
	void getRGBColorFrom (NSString *typeName, float *red,
	        float *green, float *blue);
	NSColor *getColorFrom (NSString *typeName);
	NSColor *getSaturatedColorFrom (NSColor *color, float saturation);

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
	void drawPlatform (wxDC &dc);
	void highlightHost (TrivaGraphNode *host);
	id findHostAt (int mx, int my);
};

#endif
