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
	maxDepthToDraw = 0;
	startInterval = 0.0;
	endInterval = 1.0;
	state = TreemapState;
	current = nil;
}

void Triva2DFrame::updateTreemap()
{
	wxPaintDC dc(this);
	dc.Clear();
        
	wxCoord w, h;
	dc.GetSize(&w, &h);
        
	TimeSlice *filter = controller->getTimeSlice();
	if (current != nil){
		[current release];
	}
	current = [filter treemapWithWidth: w
				 andHeight: h
				  andDepth: maxDepthToDraw];
	[current retain];
	this->drawTreemap ((id)current);
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

void Triva2DFrame::updateDetail ()
{
	if (detailDescription == nil){
		state = TreemapState;
		Update();
		return;
	}
	wxPaintDC dc(this);
	wxCoord w, h;
	dc.GetSize(&w, &h);
	wxCoord w1, h1;
	dc.GetTextExtent (NSSTRINGtoWXSTRING(detailDescription), &w1, &h1);
	
	if (w - detailx < w1){
		detailx = detailx - (w1 - (w - detailx));
	}
	if (h - detaily < h1){
		detaily = detaily - (h1 - (h - detaily));
	}
	dc.DrawRectangle (detailx, detaily, w1, h1);
	dc.DrawText (NSSTRINGtoWXSTRING(detailDescription), detailx, detaily);
}

void Triva2DFrame::Update()
{
	if (filter == nil){
		filter = controller->getTimeSlice();
	}

	if (state == TreemapState){
		this->updateTreemap();
	}else if (state == TimeState){
		this->updateTimeline();
	}else if (state == DetailState){
		this->updateDetail();
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
				if (current != nil){
					if (maxDepthToDraw<[current maxDepth]){
						maxDepthToDraw++;
					}
				}
			}else{
				if (maxDepthToDraw > 0){
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
			return;
		}

		/* trying to find which object is under the mouse */
		long x = evt.GetX();
		if (evt.LeftDown()){
			this->searchAndShowDescriptionAt (x, y);
			state = DetailState;
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
	}else if (state == DetailState){
		long y = evt.GetY();
		long x = evt.GetX();
		if (evt.LeftDown()){
			this->searchAndShowDescriptionAt (x, y);
		}else if (evt.RightDown()){
			state = TreemapState;
		}
		Update();	
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

	if ([treemap val] == 0){
		return;
	}

	float x, y, w, h;
	x = [[treemap rect] x];
	y = [[treemap rect] y];
	w = [[treemap rect] width];
	h = [[treemap rect] height];

	wxColour color;
	wxColour white = (wxT("#FFFFFF"));
	dc.SetBrush (wxBrush (white));
	if (filter && ![filter isContainerEntityType: 
			[[treemap pajeEntity] entityType]]) {
		NSColor *c = [filter colorForValue: [treemap name]
			ofEntityType: [[treemap pajeEntity] entityType]];
		if (c != nil){
			if ([[c colorSpaceName] isEqualToString:
					@"NSCalibratedRGBColorSpace"]){
				float red, green, blue, alpha;
				[c getRed: &red green: &green
					blue: &blue alpha: &alpha];
				unsigned char r = (unsigned char)(red*255);
				unsigned char g = (unsigned char)(green*255);
				unsigned char b = (unsigned char)(blue*255);
				unsigned char a = (unsigned char)(alpha*255);
				color = wxColour (r,g,b,a);
				dc.SetBrush (wxBrush(color));
			}
		}
	}
	wxRect rect (x, y, w, h);

	if ([[treemap children] count] == 0) {
		wxColour white = (wxT("#FFFFFF"));
		if (w > h){
			dc.GradientFillLinear (rect, white, color, wxNORTH);
		}else{
			dc.GradientFillLinear (rect, white, color, wxEAST);
		}
	}

//	dc.SetPen (wxPen(white, 0, wxSOLID));
//   	dc.DrawRectangle (x, y, w, h);

	wxPoint points[5];
	points[0] = wxPoint (x,y);
	points[1] = wxPoint (x+w, y);
	points[2] = wxPoint (x+w, y+h);
	points[3] = wxPoint (x, y+h);
	points[4] = wxPoint (x,y);

     
     	wxCoord w1, h1;
     	dc.GetTextExtent (NSSTRINGtoWXSTRING([treemap name]), &w1, &h1);
     	if (w1 < w-5 && h1 < h-5){
     		dc.DrawText (NSSTRINGtoWXSTRING([treemap name]), x+5, y+5);
	}

	
	if ([[treemap children] count] == 0)
		return;

	int depth = [treemap depth];
	if ((int)depth == (int)maxDepthToDraw+1){
		return;
	}
	
	unsigned int i;
	for (i = 0; i < [[treemap children] count]; i++){
		this->drawTreemap ([[treemap children] objectAtIndex: i]);
	}

	/* after drawing everything */
	if (depth < maxDepthToDraw-1){
		color = wxColour (wxT("#000000"));	
		dc.SetPen(wxPen(color, (maxDepthToDraw-depth), wxSOLID));
		dc.DrawLines (5, points);
	}
}

Treemap *Triva2DFrame::searchNodeAt (int x, int y, Treemap *node)
{
	if (node == nil){
		return nil;
	}
	int depth = [node depth];
	if (depth == maxDepthToDraw+1 || 
		depth == [node maxDepth]){
		float xr, yr, wr, hr;
		xr = [[node rect] x];
		yr = [[node rect] y];
		wr = [[node rect] width];
		hr = [[node rect] height];
	
		if (x >= xr && x <= (xr+wr) &&
			y >= yr && y <= (yr+hr)){
			return node;
		}
	}else{
		unsigned int i;
		for (i = 0; i < [[node children] count]; i++){
			Treemap *child, *ret;
			child = [[node children] objectAtIndex: i];
			ret = this->searchNodeAt (x, y, child);
			if (ret != nil){
				return ret;
			}
		}
	}
	return nil;
}

void Triva2DFrame::searchAndShowDescriptionAt (long x, long y)
{
	if (filter){
		Treemap *node = this->searchNodeAt (x, y, current);
		detailDescription = [filter descriptionForNode: node];
		detailx = x; 
		detaily = y;
	}
}
