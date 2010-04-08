#include "GraphDraw.h"
#include <wx/dcps.h>
#include <wx/paper.h>
#include <float.h>

#define CAIRO 1

#ifdef CAIRO
#include <gdk/gdk.h>
#include <gtk/gtk.h>
#include <cairo.h>
#endif


#define X(pos,bb,w) (pos.x/bb.size.width*w)
#define Y(pos,bb,h) (pos.y/bb.size.height*h)
#define WIDTH(size,bb,w) (size.size.width/bb.size.width*w)
#define HEIGHT(size,bb,h) (size.size.height/bb.size.height*h)

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);

IMPLEMENT_CLASS( GraphDraw, wxControl )
BEGIN_EVENT_TABLE( GraphDraw, wxControl )
        EVT_MOUSE_EVENTS( GraphDraw::OnMouseEvent )
        EVT_KEY_DOWN( GraphDraw::OnKeyDownEvent )
        EVT_PAINT( GraphDraw::OnPaint )
        EVT_SIZE( GraphDraw::OnSize )
//        EVT_CHAR( GraphDraw::OnCharEvent )
//        EVT_KEY_UP( GraphDraw::OnKeyUpEvent )
//        EVT_MOUSE_CAPTURE_LOST( GraphDraw::OnMouseCapureLost )
END_EVENT_TABLE ()

wxColour NSCOLORtoWXCOLOUR (NSColor *color)
{
	if (color){
		if ([[color colorSpaceName] isEqualToString: @"NSCalibratedRGBColorSpace"]){
			float red, green, blue, alpha;
			[color getRed: &red green: &green blue: &blue alpha: &alpha];
			unsigned char r = (unsigned char)(red*255);
			unsigned char g = (unsigned char)(green*255);
			unsigned char b = (unsigned char)(blue*255);
			unsigned char a = (unsigned char)(alpha*255);
			return wxColour (r,g,b,a);
		}
	}
	return wxColour (0,0,1,0);
}

NSColor *GraphDraw::getSaturatedColorFrom (NSColor *color, float saturation)
{
	if (![[color colorSpaceName] isEqualToString:
		@"NSCalibratedRGBColorSpace"]){
		NSLog (@"%s:%d Color provided is not part of the "
			"RGB color space.", __FUNCTION__, __LINE__);
		return nil;
	}
	float h, s, b, a;
	[color getHue: &h saturation: &s brightness: &b alpha: &a];

	NSColor *ret = [NSColor colorWithCalibratedHue: h
		saturation: saturation
		brightness: b
		alpha: a];
	return ret;

}

NSColor *GraphDraw::getColorFrom (NSString *typeName)
{
	NSColor *ret = [NSColor blackColor];
	if (typeName && [filter entityTypeWithName: typeName]){
		ret = [filter colorForEntityType:
			[filter entityTypeWithName: typeName]];
		if (![[ret colorSpaceName] isEqualToString:
			@"NSCalibratedRGBColorSpace"]){
			ret = [NSColor blackColor];
		}
	}
	return ret;
}

void GraphDraw::getRGBColorFrom (NSString *typeName, float *red,
	float *green, float *blue)
{
	float alpha;
	*red = *green = *blue = 0;
	if (!typeName || ![filter entityTypeWithName: typeName]){
		return;
	}
	NSColor *color = [filter colorForEntityType:
			[filter entityTypeWithName: typeName]];
	if ([[color colorSpaceName] isEqualToString:
			@"NSCalibratedRGBColorSpace"]){
		[color getRed: red green: green
			blue: blue alpha: &alpha];
	}
	return;
}

GraphDraw::GraphDraw (wxWindow *parent, wxWindowID id,
	const wxPoint &pos, const wxSize &size, long style,
	const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);
}

void GraphDraw::drawNode (cairo_t *cr, TrivaGraphNode *node)
{
	NSString *type;
	NSEnumerator *en;
	NSDictionary *types;

	/* begin old code */
	wxClientDC dc(this);
	wxCoord w, h;
	dc.GetSize(&w, &h);
	/* end old code */

	if (![node drawable]) return;
	NSPoint pos = [filter positionForNode: node];
	NSRect size = [filter sizeForNode: node];
	NSRect bb = [filter sizeForGraph];

	types = [filter enumeratorOfValuesForNode: node];
	en = [types keyEnumerator];
	double x = X(pos,bb,w);
	double y = Y(pos,bb,h);
	double nw = size.size.width;
	double nh = size.size.height;

	cairo_set_source_rgb (cr, 0, 0, 0);
	cairo_set_line_width (cr, 0.5);
	cairo_move_to (cr, x-nw/2, y-nh/2);
	cairo_rel_line_to (cr, nw, 0);
	cairo_rel_line_to (cr, 0, nh);
	cairo_rel_line_to (cr, -nw, 0);
	cairo_rel_line_to (cr, 0, -nh);
	cairo_stroke(cr);

	if ([node separation] || [node color]){
		double accum_y = 0;
		while ((type = [en nextObject])){
			double value = [[types objectForKey: type] doubleValue];
			if (value){
				double type_nw = nw;
				double type_nh = nh*value;
        
				double a = x - nw/2;
				double b = y - nh/2 + accum_y;
				double c = type_nw;
				double d = type_nh;
        
				float red, green, blue;
				this->getRGBColorFrom(type,&red, &green, &blue);
				cairo_set_source_rgb (cr, red, green, blue);
				cairo_rectangle (cr, a, b, c, d);
				cairo_fill (cr);
				accum_y += type_nh;
			}
		}
	}else if ([node gradient]){
		NSColor *color = this->getColorFrom([node gradientType]);
		double saturation = [node gradientValue] / 
				([node gradientMax] - [node gradientMin]);
		color = this->getSaturatedColorFrom (color, saturation);
		float red, green, blue, alpha;
		[color getRed: &red green: &green blue: &blue alpha: &alpha];
		cairo_set_source_rgb (cr, red, green, blue);

		double a = x - nw/2;
		double b = y - nh/2;
		double c = nw;
		double d = nh;
		cairo_rectangle (cr, a, b, c, d);
		cairo_fill (cr);
	}
}

void GraphDraw::drawEdge (cairo_t *cr, TrivaGraphEdge *edge)
{
	NSColor *color;
	NSString *type;
	NSEnumerator *en;
	NSDictionary *types;

	/* begin old code */
	wxClientDC dc(this);
	wxCoord w, h;
	dc.GetSize(&w, &h);
	/* end old code */

	if (![edge drawable]) return;
	TrivaGraphNode *src = [edge source];
	TrivaGraphNode *dst = [edge destination];
	//if ([src isEqualToString: dst]) continue;
	NSPoint src_pos = [filter positionForNode: src];
	NSPoint dst_pos = [filter positionForNode: dst];
	NSRect bb = [filter sizeForGraph];
	double bw = [filter sizeForEdge: edge].size.width;

	double x1 = src_pos.x / bb.size.width * w;
	double y1 = src_pos.y / bb.size.height * h;
	double x2 = dst_pos.x / bb.size.width * w;
	double y2 = dst_pos.y / bb.size.height * h;

	double distance = sqrt ((x2*x2 - 2*x2*x1 + x1*x1) + (y2*y2 - 2*y2*y1 + y1*y1) );
	double k = 10/distance; // remove 10% of the distance (5% on each endpoint)
	double x = x1 + k*x2 - k*x1;
	double y = y1 + k*y2 - k*y1;
	x1 = x;
	y1 = y;
	k = 1 - k;
	x = x1 + k*x2 - k*x1;
	y = y1 + k*y2 - k*y1;
	x2 = x;
	y2 = y;

	double ox1,oy1;
	double ox2,oy2;
	double ox3,oy3;
	double ox4,oy4;

	double topx = -y2 + y1;
	double topy = x2 - x1;
	double norma_de_top = sqrt ( (topx*topx) + (topy*topy) );

	double bwe = bw/2; //split the value in 2 to calculate points

	ox1 = topx/norma_de_top*bwe + x2;
	oy1 = topy/norma_de_top*bwe + y2;
	
	ox2 = topx/norma_de_top*bwe + x1;
	oy2 = topy/norma_de_top*bwe + y1;

	ox3 = -topx/norma_de_top*bwe + x1;
	oy3 = -topy/norma_de_top*bwe + y1;

	ox4 = -topx/norma_de_top*bwe + x2;
	oy4 = -topy/norma_de_top*bwe + y2;

	cairo_set_source_rgb (cr, 0, 0, 0);
	cairo_set_line_width (cr, 0.5);
	cairo_move_to (cr, ox1, oy1);
	cairo_line_to (cr, ox2, oy2);
	cairo_line_to (cr, ox3, oy3);
	cairo_line_to (cr, ox4, oy4);
	cairo_line_to (cr, ox1, oy1);
	cairo_stroke(cr);

	double lucx = ox3 - ox2;
	double lucy = oy3 - oy2;
	double norma_de_luc = sqrt ( (lucx*lucx) + (lucy*lucy) );

	if ([edge separation] || [edge color]){
		types = [filter enumeratorOfValuesForEdge: edge];
		en = [types keyEnumerator];
		while ((type = [en nextObject])){
			color = [filter colorForEntityType:
					[filter entityTypeWithName: type]];
			double value = [[types objectForKey: type] doubleValue];
			double e = bw * value;
			if (e){
		
				ox3 = lucx/norma_de_luc*e + ox1;
				oy3 = lucy/norma_de_luc*e + oy1;
                
				ox4 = lucx/norma_de_luc*e + ox2;
				oy4 = lucy/norma_de_luc*e + oy2;
                
				wxPoint points[4];
				points[0] = wxPoint (ox1, oy1);
				points[1] = wxPoint (ox2, oy2);
				points[3] = wxPoint (ox3, oy3);
				points[2] = wxPoint (ox4, oy4);
        
				float red, green, blue;
				this->getRGBColorFrom (type, &red, &green, &blue);
				cairo_set_source_rgb (cr, red, green, blue);
        
				cairo_move_to (cr, ox1, oy1);
				cairo_line_to (cr, ox2, oy2);
				cairo_line_to (cr, ox4, oy4);
				cairo_line_to (cr, ox3, oy3);
				cairo_close_path (cr);
				cairo_fill (cr);
        
				//continuing
				ox2 = ox3;
				oy2 = oy3;
        
				ox1 = ox4;
				oy1 = oy4;
			}
		}
	}else if ([edge gradient]){
		NSColor *color = this->getColorFrom([edge gradientType]);
		double saturation = [edge gradientValue] / 
				([edge gradientMax] - [edge gradientMin]);
		color = this->getSaturatedColorFrom (color, saturation);
		float red, green, blue, alpha;
		[color getRed: &red green: &green blue: &blue alpha: &alpha];
		cairo_set_source_rgb (cr, red, green, blue);

		cairo_move_to (cr, ox1, oy1);
		cairo_line_to (cr, ox2, oy2);
		cairo_line_to (cr, ox3, oy3);
		cairo_line_to (cr, ox4, oy4);
		cairo_line_to (cr, ox1, oy1);
		cairo_fill (cr);
	}
}

void GraphDraw::drawPlatform (wxDC &dc)
{
	wxCoord w, h;
	dc.GetSize(&w, &h);
	wxSize ppi = dc.GetPPI();

	wxClientDC dc_to_cairo(this);
	cairo_t* cr = gdk_cairo_create(dc_to_cairo.m_window);

	NSEnumerator *en;
	TrivaGraphNode *node;
	TrivaGraphEdge *edge;

	en = [filter enumeratorOfNodes];
	while ((node = [en nextObject])){
		this->drawNode (cr, node);
	}

	en = [filter enumeratorOfEdges];
	while ((edge = [en nextObject])){
		this->drawEdge (cr, edge);
	}
	cairo_destroy(cr);
	return;
}

void GraphDraw::OnPaint(wxPaintEvent& evt)
{
	wxPaintDC dc(this);
	dc.Clear();
	dc.SetPen(wxPen(wxT("Black"), 1, wxSOLID));
	dc.SetBrush(wxBrush(wxT("Black"), wxTRANSPARENT));
	NSString *msg = [NSString stringWithFormat: @"%@-%@",
		[filter selectionStartTime], [filter selectionEndTime]];
	dc.DrawText (NSSTRINGtoWXSTRING(msg), 0, 0);
	this->drawPlatform (dc);
}

void GraphDraw::OnSize (wxSizeEvent& evt)
{
	Refresh();
}

id GraphDraw::findHostAt (int mx, int my)
{
	wxPaintDC dc(this);
	wxCoord w, h;
	NSEnumerator *en;
	TrivaGraphNode *node;

	dc.GetSize(&w, &h);
	en = [filter enumeratorOfNodes];
	while ((node = [en nextObject])){
		NSPoint pos = [filter positionForNode: node];
		NSRect size = [filter sizeForNode: node];
		NSRect bb = [filter sizeForGraph];

		double nw = size.size.width;
		double nh = size.size.height;
		double x = X(pos,bb,w);
		double y = Y(pos,bb,h);
	
		if (mx > (x - nw/2) && mx < (x + nw/2) &&
			my > (y - nh/2) && my < (y + nh/2)){
			return node;
		}
	}
	return nil;
}

void GraphDraw::highlightHost (TrivaGraphNode *node)
{
	NSString *msg = [NSString stringWithFormat: @"%@",
		[node name]];//, [host valueOfFieldNamed: @"Power"]];
	window->setStatusMessage (NSSTRINGtoWXSTRING(msg));
}

void GraphDraw::OnMouseEvent(wxMouseEvent& evt)
{
	static double lx = 0;
	static double ly = 0;
	wxPaintDC dc(this);
	wxCoord w, h;
	dc.GetSize(&w, &h);

 	TrivaGraphNode *node = this->findHostAt (evt.GetX(), evt.GetY());
	if (node){
		this->highlightHost (node);
	}
	NSRect bb = [filter sizeForGraph];
	if (evt.Dragging() && node){
		NSPoint pos = [filter positionForNode: node];
		double x = evt.GetX();
		double y = evt.GetY();
		NSPoint np;
		np.x = x/w*bb.size.width;
		np.y = y/h*bb.size.height;
		[node setPosition: np];
		Refresh();
	}
	return;
/*
	static double lx = 0;
	static double ly = 0;
	wxPaintDC dc(this);
	wxCoord w, h;
	dc.GetSize(&w, &h);

	NSRect bb = [filter sizeForGraph];

	this->SetFocus();
	if (evt.LeftDown() || evt.RightDown()){
		lx = (double)evt.GetX() / (double)w * bb.size.width;
		ly = (double)evt.GetY() / (double)h * bb.size.height;
	}else if (evt.Dragging() && host){

		NSPoint pos = [filter getPositionForHost: host];

		double x = (double)evt.GetX() / (double)w * bb.size.width;
		double y = (double)evt.GetY() / (double)h * bb.size.height;
		double xdif = (x - lx);
		double ydif = (y - ly);

		double nx = (pos.x+xdif);
		double ny = (pos.y+ydif);

		NSPoint np;
		np.x = nx;
		np.y = ny;
		[filter setPositionForHost: host toPoint: np];
		Refresh();
		lx = x;
		ly = y;
	}else{
		this->highlightHost (node);
	}
*/
/*	//Selection of states for one-state representation disabled
	if (evt.LeftDown()){
		long x = evt.GetX();
		long y = evt.GetY();
		Graph *node = [current searchWithX: x
		                andY: y
		                limitToDepth: maxDepthToDraw];
		[selectedValues addObject: [[node pajeEntity] value]];
		Update(true);
		return;
	}
	if (evt.GetWheelRotation() != 0){
		if (evt.GetWheelRotation() > 0){
			if (current != nil){
				if (maxDepthToDraw < (int)[current maxDepth]){
					maxDepthToDraw++;
				}
			}
		}else{
			if (maxDepthToDraw > 0){
				maxDepthToDraw--;
			}
		}
		highlighted = nil;
		Refresh();
	}
*/
}

void GraphDraw::OnKeyDownEvent(wxKeyEvent& evt)
{
	if (evt.AltDown() && evt.GetKeyCode() == 80) { /* ALT + P */
		wxClientDC screen(this);
	        wxCoord w, h;
	        screen.GetSize (&w, &h);
	        NSString *filename = @"teste"; //[NSString stringWithFormat:
//	                @"output-%d-%d-%d.ps", maxDepthToDraw, w, h];
	        wxPrintData data;
	        data.SetPrintMode (wxPRINT_MODE_FILE);
	        data.SetPaperId(wxPAPER_A3);
	        data.SetFilename (NSSTRINGtoWXSTRING(filename));
	        wxPostScriptDC dc(data);
	        if (!dc.Ok()){
	                NSString *msg = [NSString stringWithFormat:
	                        @"Error in printing"];
	                window->setStatusMessage (NSSTRINGtoWXSTRING(msg));
	                return;
	        }else{
			dc.StartDoc(NSSTRINGtoWXSTRING(filename));
//			this->drawGraph ((id)current, dc);
			dc.EndDoc();
			NSString *msg = [NSString stringWithFormat:
			        @"Printed to %@", filename];
			window->setStatusMessage (NSSTRINGtoWXSTRING(msg));
	        }
	}
}


/*
 * The following methods are always called by previous methods in this file
 */

/* Highlight related methods */
/*
void GraphDraw::highlightGraphNode (long x, long y)
{
        if (current){
                id node = [current searchWithX: x
                                andY: y
                                limitToDepth: maxDepthToDraw];
                if (node != highlighted){
                        wxPaintDC dc(this);
                        this->unhighlightGraphNode(dc);
                        this->drawHighlightGraphNode (node, dc);
                        highlighted = node;
                }
        }
}

void GraphDraw::unhighlightGraphNode (wxDC &dc)
{
        wxColour grayColor = wxColour (wxT("#c0c0c0"));
        wxColour color;
        wxBrush brush;

        id parent = [[highlighted parent] parent];
        while (parent){
                color = this->findColorForNode (parent);
		brush = wxBrush (color, wxTRANSPARENT);
                this->drawGraphNode (parent, 0, brush, grayColor, dc);
                if ([parent parent] == nil){
                        break;
                }else{
                        parent = [parent parent];
                }
        }
	
	unsigned int i;
	for (i = 0; i < [[[highlighted parent] aggregatedChildren] count]; i++){
		id agg = [[[highlighted parent] aggregatedChildren] objectAtIndex: i];
	        color = this->findColorForNode (agg);
        	brush = wxBrush (color, wxSOLID);
        	this->drawGraphNode (agg, 0, brush, grayColor, dc);
	}
}

void GraphDraw::drawHighlightGraphNode (id node, wxDC &dc)
{
        wxColour blackColor = wxColour (wxT("#000000"));
        wxColour color = this->findColorForNode (node);
        wxBrush brush (color, wxTRANSPARENT);
        this->drawGraphNode (node, 1, brush, blackColor, dc);

        NSMutableString *message;
        message = [NSMutableString stringWithFormat: @"%.3f - %@",
                                [node val], [node name]];
        id parent = [node parent];
        while (parent){
                color = this->findColorForNode (parent);
                this->drawGraphNode (parent, 0, brush, blackColor, dc);
                [message appendString: [NSString stringWithFormat: @" - %@",
                        [parent name]]];
                if ([[parent parent] depth] == 0){
                        break;
                }else{
                        parent = [parent parent];
                }
        }
        window->setStatusMessage (NSSTRINGtoWXSTRING(message));
}

void GraphDraw::drawGraphNode (id node, int offset,
                        wxBrush &brush, wxColour &color,
                        wxDC &dc)
{
        if (node == nil){
                return;
        }

        // get x,y,w,h from the treemap node 
        float x, y, w, h;
        x = [[node treemapRect] x];
        y = [[node treemapRect] y];
        w = [[node treemapRect] width];
        h = [[node treemapRect] height];

        // highlight the treemap node 
        wxPoint points[5];
        points[0] = wxPoint (x+offset,y+offset);
        points[1] = wxPoint (x+w-offset, y+offset);
        points[2] = wxPoint (x+w-offset, y+h-offset);
        points[3] = wxPoint (x+offset, y+h-offset);
        points[4] = wxPoint (x+offset,y+offset);

        // draw a rectangle with the color found and a gray outline 
	if (brush != wxNullBrush){
		dc.SetBrush (brush);
	}
        dc.SetPen(wxPen(color, 1, wxSOLID));
        dc.DrawPolygon (5, points);
}

wxColour GraphDraw::findColorForNode (id treemap)
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
                color = wxColour (wxT("#FFFFFF"));
        }
        return color;
}

void GraphDraw::drawGraph (id treemap, wxDC &dc)
{
	if ([treemap val] == 0){
		return;
	}
	if ([treemap depth] == maxDepthToDraw){
		//draw aggregates
                unsigned int nAggChildren, i;
                nAggChildren = [[treemap aggregatedChildren] count];
                for (i = 0; i < nAggChildren; i++){
			id child = [[treemap aggregatedChildren]
					objectAtIndex: i];
			wxColour color = this->findColorForNode (child);
			dc.SetBrush (color);
			wxBrush brush (color, wxSOLID);
			wxColour grayColor = wxColour (wxT("#c0c0c0"));
			this->drawGraphNode (child, 0, brush, grayColor, dc);
		}
		
	}else{
		//recurse
		unsigned int i;
		for (i = 0; i < [[treemap children] count]; i++){
			this->drawGraph ([[treemap children]
				objectAtIndex: i], dc);
		}
	}
}
*/

