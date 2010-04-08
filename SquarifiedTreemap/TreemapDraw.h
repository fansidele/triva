#ifndef __TreemapDraw__
#define __TreemapDraw__

#include <Foundation/Foundation.h>
#include "wx/wx.h"
#include "Treemap.h"
#include <General/PajeFilter.h>
#include "TreemapWindow.h"

class TreemapWindow;

class TreemapDraw : public wxControl
{
	DECLARE_CLASS (TreemapDraw)
	DECLARE_EVENT_TABLE ()
	DECLARE_NO_COPY_CLASS (TreemapDraw)

private:
	TreemapWindow *window;
	int maxDepthToDraw;
	id current, highlighted;
	NSMutableSet *selectedValues;
	id filter;

public:
	TreemapDraw (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
	void setController (id contr) { filter = contr; };
	void setWindow (TreemapWindow *w) { window = w; };

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
	void highlightTreemapNode (long x, long y);
	void unhighlightTreemapNode (wxDC &dc);

	/* drawing related methods */
	void drawHighlightTreemapNode (id node, wxDC &dc);
	void drawTreemapNode (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	void drawTreemapNode2 (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc);
	wxColour findColorForNode (id treemap);
	void drawTreemap (id treemap, wxDC &dc);
};

#endif
