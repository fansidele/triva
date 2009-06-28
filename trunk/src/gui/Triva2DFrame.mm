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
        
	if (current != nil){
		[current release];
	}
	current = [filter treemapWithWidth: w
				 andHeight: h
				  andDepth: maxDepthToDraw];
	[current retain];

        
	this->drawTreemap ((id)current, dc);
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
	bool firsttime = false;
	filter = controller->getTimeSlice();
	if (!firsttime){
		[filter setSliceStartTime: [filter startTime]];
		[filter setSliceEndTime: [filter endTime]];
		firsttime = true;
	}

	if (state == TreemapState){
		this->updateTreemap();
	}else if (state == TimeState){
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

	this->highlightTreemapNode (evt.GetX(), evt.GetY());

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
			highlighted = nil;
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

void Triva2DFrame::drawTreemap (id treemap, wxDC &dc)
{
	/* do not consider the part of the three with value 0 */
	if ([treemap val] == 0){
		return;
	}

	/* only draw leaf-nodes */
	if ([[treemap children] count] != 0) {
		/* recurse */	
		unsigned int i;
		for (i = 0; i < [[treemap children] count]; i++){
			this->drawTreemap ([[treemap children] objectAtIndex: i], dc);
		}
		return;
	}

	/* try to find a color already used by the paje filters */
	wxColour color = findColorForNode ((Treemap *)treemap);

	/* draw a rectangle with the color found and a gray outline */
	dc.SetBrush (color);
	wxBrush brush (color, wxSOLID);
	wxColour grayColor = wxColour (wxT("#c0c0c0"));
	this->drawTreemapNode ((Treemap *)treemap, 0, brush, grayColor, dc);
}

void Triva2DFrame::highlightTreemapNode (long x, long y)
{
	if (current){
		Treemap *node = [current searchWithX: x andY: y];
		if (node != highlighted){
			wxPaintDC dc(this);
			this->unhighlightTreemapNode(dc);
			this->drawHighlightTreemapNode (node, dc);
			highlighted = node;
		}
	}
}

void Triva2DFrame::drawHighlightTreemapNode (Treemap *node, wxDC &dc)
{
	wxColour blackColor = wxColour (wxT("#000000"));
	wxColour color = findColorForNode (node);
	wxBrush brush (color, wxTRANSPARENT);
	this->drawTreemapNode (node, 1, brush, blackColor, dc);

	Treemap *parent = (Treemap *)[node parent];
	while (parent){
		color = findColorForNode (parent);
		brush = wxBrush (color, wxTRANSPARENT);
		this->drawTreemapNode (parent, 0, brush, blackColor, dc);
		if ([parent parent] == nil){
			break;
		}else{
			parent = (Treemap *)[parent parent];
		}
	}

	/* setting message in the status bar */
	NSMutableString *message;
	message = [NSMutableString stringWithFormat: @"%.3f - %@",
				[node val], [node name]];
	while (parent){
		[message appendString: [NSString stringWithFormat: @" - %@",
			[parent name]]];
		parent = (Treemap *)[parent parent];
	}
	controller->setStatusMessage (NSSTRINGtoWXSTRING(message));
}

void Triva2DFrame::unhighlightTreemapNode (wxDC &dc)
{
	wxColour grayColor = wxColour (wxT("#c0c0c0"));
	wxColour color;
	wxBrush brush;

	Treemap *parent = (Treemap *)[highlighted parent];
	while (parent){
		color = findColorForNode (parent);
		brush = wxBrush (color, wxTRANSPARENT);
		this->drawTreemapNode (parent, 0, brush, grayColor, dc);
		if ([parent parent] == nil){
			break;
		}else{
			parent = (Treemap *)[parent parent];
		}
	}

	color = findColorForNode (highlighted);
	brush = wxBrush (color, wxSOLID);
	this->drawTreemapNode (highlighted, 0, brush, grayColor, dc);

}

void Triva2DFrame::drawTreemapNode (Treemap *node, int offset,
			wxBrush &brush, wxColour &color,
			wxDC &dc)
{
	if (node == nil){
		return;
	}

	/* get x,y,w,h from the treemap node */
	float x, y, w, h;
	x = [[node rect] x];
	y = [[node rect] y];
	w = [[node rect] width];
	h = [[node rect] height];

	/* highlight the treemap node */
	wxPoint points[5];
	points[0] = wxPoint (x+offset,y+offset);
	points[1] = wxPoint (x+w-offset, y+offset);
	points[2] = wxPoint (x+w-offset, y+h-offset);
	points[3] = wxPoint (x+offset, y+h-offset);
	points[4] = wxPoint (x+offset,y+offset);

	/* draw a rectangle with the color found and a gray outline */
	dc.SetBrush (brush);
	dc.SetPen(wxPen(color, 1, wxSOLID));
	dc.DrawPolygon (5, points);
}

wxColour Triva2DFrame::findColorForNode (Treemap *treemap)
{
	wxColour color;
	if (filter && ![filter isContainerEntityType: 
			(PajeEntityType *)[[treemap pajeEntity] entityType]]) {
		NSColor *c = [filter colorForValue: [treemap name]
			ofEntityType: (PajeEntityType *)[[treemap pajeEntity] entityType]];
		if (c != nil){
			float red, green, blue, alpha;
			c = [c colorUsingColorSpaceName:
				@"NSCalibratedRGBColorSpace"];
			[c getRed: &red green: &green
				blue: &blue alpha: &alpha];
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
			}
		}
	}else{
		/* fallback to white color */
		color = wxColour (wxT("#FFFFFF"));	
	}
	return color;
}
