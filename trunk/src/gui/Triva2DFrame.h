#ifndef __TRIVA2DFRAME_H__
#define __TRIVA2DFRAME_H__

#include "wx/wxprec.h"
#include "wx/wx.h"
#include "wx/xrc/xmlres.h"

class Triva2DFrame : public wxControl
{
   DECLARE_CLASS( Triva2DFrame )
   DECLARE_EVENT_TABLE()
   DECLARE_NO_COPY_CLASS( Triva2DFrame )

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
};

#endif   // __TRIVA2DFRAME_H__ 