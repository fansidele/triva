#include "Triva2DFrame.h"
#include "gui/TrivaController.h"
#include "time-slice/TimeSlice.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

#if defined(__WXGTK__)
   // NOTE: Find the GTK install config with `pkg-config --cflags gtk+-2.0`
   #include "gtk/gtk.h"
   #include "gdk/gdk.h"
   #include "gdk/gdkx.h"
   #include "wx/gtk/win_gtk.h"
   #include "GL/glx.h"
#endif

#define TL_PROXIMITY 20
#define TL_BOXHEIGHT 30
#define TL_BORDER 5
static int startTimeIntervalX;
static int endTimeIntervalX;
static bool startProximity;
static bool endProximity;

IMPLEMENT_CLASS( Triva2DFrame, wxControl )

BEGIN_EVENT_TABLE( Triva2DFrame, wxControl )
	EVT_SIZE( Triva2DFrame::OnSize )
	EVT_MOUSE_EVENTS( Triva2DFrame::OnMouseEvent )
	EVT_CHAR( Triva2DFrame::OnCharEvent )
	EVT_KEY_DOWN( Triva2DFrame::OnKeyDownEvent )
	EVT_KEY_UP( Triva2DFrame::OnKeyUpEvent )
	EVT_PAINT( Triva2DFrame::OnPaint )
	EVT_MOUSE_CAPTURE_LOST( Triva2DFrame::OnMouseCapureLost )
END_EVENT_TABLE ()

Triva2DFrame::Triva2DFrame()
{
	Init();
}

Triva2DFrame::Triva2DFrame (wxWindow *parent, wxWindowID id,
                const wxPoint &pos,
                const wxSize &size,
                long style,
                const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);
}

bool Triva2DFrame::Create(wxWindow *parent, wxWindowID id,
                const wxPoint &pos,
                const wxSize &size,
                long style,
                const wxValidator &validator)
{
	if (!wxControl::Create(parent, id, pos, size, style, validator)){
		return false;
	}
	return true;
}


Triva2DFrame::~Triva2DFrame()
{
}

void Triva2DFrame::Init()
{
	maxDepthToDraw = 10;
	startInterval = 0.0;
	endInterval = 1.0;
	state = TreemapState;
}

void Triva2DFrame::updateTreemap()
{
	wxPaintDC dc(this);
	dc.Clear();
        
	wxCoord w, h;
	dc.GetSize(&w, &h);
        
	TimeSlice *filter = controller->getTimeSlice();
	Treemap *tree = [filter treemapWithWidth: w andHeight: h];
	this->drawTreemap ((id)tree);
}

void Triva2DFrame::updateTimeline()
{
	wxPaintDC dc(this);

	wxCoord w, h;
	dc.GetSize(&w, &h);

	/* drawing the timeline rectangle */
	wxColour black = (wxT("#000000"));	
	dc.SetPen (wxPen(black, 1, wxSOLID));		
	dc.DrawRectangle (0, h-TL_BOXHEIGHT, w, TL_BOXHEIGHT);

	/* drawing the timeline itself */
	dc.SetPen (wxPen(black, 3, wxSOLID));
	dc.DrawLine (TL_BORDER, h-TL_BORDER, w-TL_BORDER, h-TL_BORDER);
	dc.DrawLine (TL_BORDER, h-7, TL_BORDER, h-3);
	dc.DrawLine (w-TL_BORDER, h-7, w-TL_BORDER, h-3);

	/* drawing the max and min time */
	TimeSlice *filter = controller->getTimeSlice();
	NSString *start = [[filter startTime] description];
	NSString *end = [[filter endTime] description];
	dc.DrawText (NSSTRINGtoWXSTRING(start), TL_BORDER, h-29);
	wxCoord w1, h1;
	dc.GetTextExtent (NSSTRINGtoWXSTRING(end), &w1, &h1);
	dc.DrawText (NSSTRINGtoWXSTRING(end), w-TL_BORDER-w1, h-29);

	/* drawing the time interval */
	int startX = TL_BORDER + (w - 2*TL_BORDER) * startInterval;
	int endX = TL_BORDER + (w - 2*TL_BORDER) * endInterval;
	wxColour green = (wxT("#00ff00"));	
	wxColour red = (wxT("#ff0000"));	
	dc.SetPen (wxPen(green, 3, wxCROSS_HATCH ));		
	dc.DrawLine (startX, h-TL_BORDER, endX, h-TL_BORDER);
	dc.SetPen (wxPen(red, 3, wxSOLID));
	dc.DrawLine (startX, h-7, startX, h-3);
	dc.DrawLine (endX, h-7, endX, h-3);

	double s = [start doubleValue];
	double e = [end doubleValue];
	double dif = e - s;
	s = dif*startInterval;
	e = dif*endInterval;
	NSDate *nStartTime, *nEndTime;
	nStartTime = [NSDate dateWithTimeIntervalSinceReferenceDate: s];
	nEndTime = [NSDate dateWithTimeIntervalSinceReferenceDate: e];
	[filter setSliceStartTime: nStartTime];
	[filter setSliceEndTime: nEndTime];
	dc.SetPen (wxPen (black, 1, wxSOLID));
	dc.DrawText (NSSTRINGtoWXSTRING (
		[nStartTime description]),
		startX, h-29);
	dc.DrawText (NSSTRINGtoWXSTRING (
		[nEndTime description]),
		endX, h-29);
	//saving startX and endX in global variable
	startTimeIntervalX = startX;
	endTimeIntervalX = endX;
}

void Triva2DFrame::Update()
{
	if (state == TreemapState){
		this->updateTreemap();
	}else if (state == TimeState){
		this->updateTimeline();
		this->updateTreemap();
		this->updateTimeline();
	}
}

void Triva2DFrame::OnSize(wxSizeEvent& evt)
{
	Update();
	evt.Skip();
}

void Triva2DFrame::OnMouseEvent(wxMouseEvent& evt)
{
	static int xant;

	this->SetFocus();
	if (state == TreemapState){
		if (evt.GetWheelRotation() != 0){
			if (evt.GetWheelRotation() > 0){
				maxDepthToDraw++;
			}else{
				if (maxDepthToDraw != 0){
					maxDepthToDraw--;
				}
			}
			Update();
		}
		/* conditionaly moving to Time state */
		long y = evt.GetY();
		wxPaintDC dc(this);
		wxCoord w, h;
		dc.GetSize(&w, &h);
		if (y > (h-3)){
			state = TimeState;
			Update();
		}
	}else if (state == TimeState){
		//Time state
		long y = evt.GetY();
		long x = evt.GetX();
		wxPaintDC dc(this);
		wxCoord w, h;
		dc.GetSize(&w, &h);
		if (y < (h-(TL_BOXHEIGHT*2))){
			state = TreemapState;
			Update();
		}else{
			if (fabs(x - startTimeIntervalX) < TL_PROXIMITY &&
				fabs (y - (h-TL_BOXHEIGHT)) < TL_PROXIMITY){
				startProximity = true;
			}else if (fabs(x - endTimeIntervalX) < TL_PROXIMITY &&
				fabs (y - (h-TL_BOXHEIGHT)) < TL_PROXIMITY){
				endProximity = true;
			}else{
				startProximity = false;
				endProximity = false;
			}
		}
		if (startProximity && evt.LeftDown()){
			xant = x - startTimeIntervalX;
		}else if (endProximity && evt.LeftDown()){
			xant = endTimeIntervalX - x;
		}
		if (evt.Dragging() && startProximity){
			startTimeIntervalX = x+xant;
			startInterval = (float)startTimeIntervalX /
					(float)(w-(TL_BORDER*2)); 
			if (startInterval < 0){
				startInterval = 0;
			}
			if (startInterval > endInterval){
				startInterval = endInterval;
			}
			Update();
		}else if (evt.Dragging() && endProximity){
			endTimeIntervalX = x-xant;
			endInterval = (float)endTimeIntervalX /
					(float)(w-(TL_BORDER*2)); 
			if (endInterval > 1.0){
				endInterval = 1;
			}
			if (endInterval < startInterval){
				endInterval = startInterval;
			}
			Update();
		}
	}
}

void Triva2DFrame::OnMouseCapureLost(wxMouseCaptureLostEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnCharEvent(wxKeyEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnKeyDownEvent(wxKeyEvent& evt)
{
	state = TreemapState;
	evt.Skip();
}

void Triva2DFrame::OnKeyUpEvent(wxKeyEvent& evt)
{
	evt.Skip();
}

void Triva2DFrame::OnRenderTimer(wxTimerEvent& evt)
{}

void Triva2DFrame::OnPaint(wxPaintEvent& evt)
{
   Update();
}

void Triva2DFrame::drawTreemap (id treemap)
{
	wxPaintDC dc(this);

	if ([treemap value] == 0){
		return;
	}

	float x, y, w, h;
	x = [treemap x];
	y = [treemap y];
	w = [treemap width];
	h = [treemap height];

	dc.DrawRectangle (x, y, w, h);
	dc.DrawText (NSSTRINGtoWXSTRING([treemap name]), x+5, y+5);

	if ([[treemap children] count] == 0)
		return;

	int depth = [treemap depth];
	if ((int)depth == (int)maxDepthToDraw){
		return;
	}
	
	unsigned int i;
	for (i = 0; i < [[treemap children] count]; i++){
		this->drawTreemap ([[treemap children] objectAtIndex: i]);
	}
}

