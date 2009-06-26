#ifndef __TRIVA2DFRAME_H__
#define __TRIVA2DFRAME_H__

#include <Foundation/Foundation.h>
#include "time-slice/Treemap.h"

#include "wx/wxprec.h"
#include "wx/wx.h"
#include "wx/xrc/xmlres.h"

class TrivaController;
	
enum Triva2DFrameState {TreemapState,TimeState,DetailState};

class Triva2DFrame : public wxControl
{
   DECLARE_CLASS( Triva2DFrame )
   DECLARE_EVENT_TABLE()
   DECLARE_NO_COPY_CLASS( Triva2DFrame )

private:
	TrivaController *controller;
	int maxDepthToDraw;
	Triva2DFrameState state;

        float startInterval;
        float endInterval;

	void updateTreemap ();
	void updateTimeline ();
	void updateDetail();

	Treemap *current;
	Treemap *highlighted;

	long detailx, detaily;
	NSString *detailDescription;
	void searchAndShowDescriptionAt (long x, long y);

	id filter;

public:
	void setController (TrivaController *c) { controller = c; };

public:
   Triva2DFrame();
   Triva2DFrame (wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
   bool Create(wxWindow *parent, wxWindowID id,
		const wxPoint &pos = wxDefaultPosition,
		const wxSize &size = wxDefaultSize,
		long style = wxSUNKEN_BORDER,
		const wxValidator &validator = wxDefaultValidator);
   ~Triva2DFrame();
   virtual void Init();
   virtual void Update();

protected:
   virtual void OnSize(wxSizeEvent& evt);
   virtual void OnMouseEvent(wxMouseEvent& evt);
   virtual void OnMouseCapureLost(wxMouseCaptureLostEvent& evt);
   virtual void OnCharEvent(wxKeyEvent& evt);
   virtual void OnKeyDownEvent(wxKeyEvent& evt);
   virtual void OnKeyUpEvent(wxKeyEvent& evt);
   virtual void OnRenderTimer(wxTimerEvent& evt);
   virtual void OnPaint(wxPaintEvent& evt);

private:
   void drawTreemap (id treemap, wxDC &dc);
   void highlightTreemapNode (long x, long y);
   void unhighlightTreemapNode (wxDC &dc);
   void drawHighlightTreemapNode (Treemap *node, wxDC &dc);
   void drawTreemapNode (Treemap *node, wxBrush &brush,
			wxColour &color, wxDC &dc);
};

#endif   // __TRIVA2DFRAME_H__ 
