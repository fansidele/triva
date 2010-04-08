#include "SimGridDraw.h"
#include <wx/dcps.h>
#include <wx/paper.h>
#include <float.h>

#define TRANSFORM(bw) (10+bw*20)

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);

IMPLEMENT_CLASS( SimGridDraw, wxControl )
BEGIN_EVENT_TABLE( SimGridDraw, wxControl )
        EVT_MOUSE_EVENTS( SimGridDraw::OnMouseEvent )
        EVT_KEY_DOWN( SimGridDraw::OnKeyDownEvent )
        EVT_PAINT( SimGridDraw::OnPaint )
        EVT_SIZE( SimGridDraw::OnSize )
//        EVT_CHAR( SimGridDraw::OnCharEvent )
//        EVT_KEY_UP( SimGridDraw::OnKeyUpEvent )
//        EVT_MOUSE_CAPTURE_LOST( SimGridDraw::OnMouseCapureLost )
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

SimGridDraw::SimGridDraw (wxWindow *parent, wxWindowID id,
	const wxPoint &pos, const wxSize &size, long style,
	const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);
	hosts = links = nil;

//	gvc = gvContext();
//	resGraph = NULL;//agopen ((char *)"SimGridGraph", AGRAPHSTRICT);
}

void SimGridDraw::drawPlatformState (wxDC &dc)
{
	wxCoord w, h;
	dc.GetSize(&w, &h);
	//draw platform state
	NSEnumerator *en, *en2;
	id host, link, type;

	en = [hosts objectEnumerator];
	while ((host = [en nextObject])){
		NSPoint pos = [filter getPositionForHost: host];
		NSRect size = [filter getSizeForHost: host];
		NSRect bb = [filter getBoundingBox];

		id typesAndValues = [filter getPowerUtilizationOfHost: host];
		en2 = [typesAndValues keyEnumerator];
		int x = pos.x / bb.size.width * w;
		int y = pos.y / bb.size.height * h;
		int nw = size.size.width;
		int nh = size.size.height;

		double accum_y = 0;
//		NSLog (@"%@", [host name]);
		while ((type = [en2 nextObject])){
			NSColor *color = [filter colorForEntityType: type];
			double value = [[typesAndValues objectForKey: type] doubleValue];
//			NSLog (@"\t%@ %f from %f", [type name], nh*value, size.size.height);

			if (value){
				dc.SetBrush(wxBrush(NSCOLORtoWXCOLOUR (color), wxSOLID));
				int type_nw = nw;
				int type_nh = nh*value;

				int a = x - nw/2;
				int b = y - nh/2 + accum_y;
				int c = type_nw;
				int d = type_nh;
				dc.DrawRectangle (a, b, c, d);
				accum_y += type_nh;
			}
		}
	}

	en = [links objectEnumerator];
	while ((link = [en nextObject])){
		NSString *src = [link valueOfFieldNamed: @"SrcHost"];
		NSString *dst = [link valueOfFieldNamed: @"DstHost"];
		if ([src isEqualToString: dst]) continue;
		NSPoint src_pos = [filter getPositionForHost: src];
		NSPoint dst_pos = [filter getPositionForHost: dst];
		NSRect bb = [filter getBoundingBox];
		float bw = [filter getSizeForLink: link];

		int x1 = src_pos.x / bb.size.width * w;
		int y1 = src_pos.y / bb.size.height * h;
		int x2 = dst_pos.x / bb.size.width * w;
		int y2 = dst_pos.y / bb.size.height * h;

		float distance = sqrt (	(x2*x2 - 2*x2*x1 + x1*x1) + (y2*y2 - 2*y2*y1 + y1*y1) );
		float k = 10/distance; // remove 10% of the distance (5% on each endpoint)
		int x = x1 + k*x2 - k*x1;
		int y = y1 + k*y2 - k*y1;
		x1 = x;
		y1 = y;
		k = 1 - k;
		x = x1 + k*x2 - k*x1;
		y = y1 + k*y2 - k*y1;
		x2 = x;
		y2 = y;

		int ox1,oy1;
		int ox2,oy2;
		int ox3,oy3;
		int ox4,oy4;

		float topx = -y2 + y1;
		float topy = x2 - x1;
		float norma_de_top = sqrt ( (topx*topx) + (topy*topy) );

		float bwe = TRANSFORM(bw)/2; //split the value in 2 to calculate points

		ox1 = topx/norma_de_top*bwe + x2;
		oy1 = topy/norma_de_top*bwe + y2;
		
		ox2 = topx/norma_de_top*bwe + x1;
		oy2 = topy/norma_de_top*bwe + y1;

		ox3 = -topx/norma_de_top*bwe + x1;
		oy3 = -topy/norma_de_top*bwe + y1;

		ox4 = -topx/norma_de_top*bwe + x2;
		oy4 = -topy/norma_de_top*bwe + y2;

		double lucx = ox3 - ox2;
		double lucy = oy3 - oy2;
		double norma_de_luc = sqrt ( (lucx*lucx) + (lucy*lucy) );

		id typesAndValues = [filter getBandwidthUtilizationOfLink: link];
		en2 = [typesAndValues keyEnumerator];
//		NSLog (@"%@", [link name]);
		while ((type = [en2 nextObject])){
			NSColor *color = [filter colorForEntityType: type];
			double value = [[typesAndValues objectForKey: type] doubleValue];
			float e = TRANSFORM(bw) * value;
//			NSLog (@"\t%@ %f (value=%f, link_bw=%f) from %f", [type name], e, value, bw, TRANSFORM(bw));
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
        
				dc.SetBrush(wxBrush(NSCOLORtoWXCOLOUR (color), wxSOLID));
				dc.DrawPolygon(4, points);

				//continuing
				ox2 = ox3;
				oy2 = oy3;

				ox1 = ox4;
				oy1 = oy4;
			}
		}
		continue;

		float e = TRANSFORM(bw);

		wxPoint points[4];
		points[0] = wxPoint (ox1, oy1);
		points[1] = wxPoint (ox2, oy2);
		points[2] = wxPoint (ox3, oy3);
		points[3] = wxPoint (ox4, oy4);

		dc.DrawPolygon(4, points);
	}
//	NSLog (@"");
}

void SimGridDraw::drawPlatform (wxDC &dc)
{
	wxCoord w, h;
	dc.GetSize(&w, &h);

	NSEnumerator *en;
	id host, link;

	en = [hosts objectEnumerator];
	while ((host = [en nextObject])){
		NSPoint pos = [filter getPositionForHost: host];
		NSRect size = [filter getSizeForHost: host];
		NSRect bb = [filter getBoundingBox];

		int nw = size.size.width;
		int nh = size.size.height;
		int x = pos.x / bb.size.width * w;
		int y = pos.y / bb.size.height * h;

		dc.SetPen(wxPen(wxT("Black"), 1, wxSOLID));
		dc.SetBrush(wxBrush(wxT("White"), wxSOLID));
		dc.DrawRectangle (x-nw/2, y-nh/2, nw, nh);
	}

	en = [links objectEnumerator];
	while ((link = [en nextObject])){
		NSString *src = [link valueOfFieldNamed: @"SrcHost"];
		NSString *dst = [link valueOfFieldNamed: @"DstHost"];
		if ([src isEqualToString: dst]) continue;
		NSPoint src_pos = [filter getPositionForHost: src];
		NSPoint dst_pos = [filter getPositionForHost: dst];
		NSRect bb = [filter getBoundingBox];
		float bw = [filter getSizeForLink: link];

		int x1 = src_pos.x / bb.size.width * w;
		int y1 = src_pos.y / bb.size.height * h;
		int x2 = dst_pos.x / bb.size.width * w;
		int y2 = dst_pos.y / bb.size.height * h;

		float e = TRANSFORM(bw);
	
		int ox1,oy1;
		int ox2,oy2;
		int ox3,oy3;
		int ox4,oy4;

		float distance = sqrt (	(x2*x2 - 2*x2*x1 + x1*x1) + (y2*y2 - 2*y2*y1 + y1*y1) );
		float k = 10/distance; // remove 10% of the distance (5% on each endpoint)
		int x = x1 + k*x2 - k*x1;
		int y = y1 + k*y2 - k*y1;
		x1 = x;
		y1 = y;
		k = 1 - k;
		x = x1 + k*x2 - k*x1;
		y = y1 + k*y2 - k*y1;
		x2 = x;
		y2 = y;

		//recalculate distance because x1,y1 and x2,y2 changed
		float ndistance = sqrt ( (y2*y2 - 2*y2*y1 + y1*y1) + (x2*x2 - 2*x2*x1 + x1*x1) );
		float top1 = y2 - y1;
		float top2 = - x2 + x1;

		e /= 2; //split the value in 2 to calculate points

		ox1 = -top1/ndistance*e + x2;
		oy1 = -top2/ndistance*e + y2;
		
		ox2 = top1/ndistance*e + x2;
		oy2 = top2/ndistance*e + y2;
		
		ox3 = top1/ndistance*e + x1;
		oy3 = top2/ndistance*e + y1;

		ox4 = -top1/ndistance*e + x1;
		oy4 = -top2/ndistance*e + y1;

//		NSLog (@"%@ o1(%d,%d)  o2(%d,%d) o3(%d,%d) o4(%d,%d)",
//			[link name], ox1, oy1, ox2, oy2, ox3, oy3, ox4, oy4);

	
		wxPoint points[4];
		points[0] = wxPoint (ox1, oy1);
		points[1] = wxPoint (ox2, oy2);
		points[2] = wxPoint (ox3, oy3);
		points[3] = wxPoint (ox4, oy4);

		dc.DrawPolygon(4, points);
	}
}

void SimGridDraw::OnPaint(wxPaintEvent& evt)
{
	wxPaintDC dc(this);
	dc.Clear();
	dc.SetPen(wxPen(wxT("Black"), 1, wxSOLID));
	dc.SetBrush(wxBrush(wxT("Black"), wxTRANSPARENT));
	NSString *msg = [NSString stringWithFormat: @"%@-%@",
		[filter selectionStartTime], [filter selectionEndTime]];
	dc.DrawText (NSSTRINGtoWXSTRING(msg), 0, 0);
	this->drawPlatform (dc);
	this->drawPlatformState (dc);
}

void SimGridDraw::OnSize (wxSizeEvent& evt)
{
	Refresh();
}

id SimGridDraw::findHostAt (int mx, int my)
{
	wxPaintDC dc(this);
	wxCoord w, h;
	NSEnumerator *en;
	id host;

	dc.GetSize(&w, &h);
	en = [hosts objectEnumerator];
	while ((host = [en nextObject])){
		NSPoint pos = [filter getPositionForHost: host];
		NSRect size = [filter getSizeForHost: host];
		NSRect bb = [filter getBoundingBox];

		int nw = size.size.width;
		int nh = size.size.height;
		int x = pos.x / bb.size.width * w;
		int y = pos.y / bb.size.height * h;
	
		if (mx > (x - nw/2) && mx < (x + nw/2) &&
			my > (y - nh/2) && my < (y + nh/2)){
			return host;
		}
	}
	return nil;
}

void SimGridDraw::highlightHost (id host)
{
	NSString *msg = [NSString stringWithFormat: @"%@ %@",
		[host name], [host valueOfFieldNamed: @"Power"]];
	window->setStatusMessage (NSSTRINGtoWXSTRING(msg));
}

void SimGridDraw::OnMouseEvent(wxMouseEvent& evt)
{
	static double lx = 0;
	static double ly = 0;
 	id host = this->findHostAt (evt.GetX(), evt.GetY());
	wxPaintDC dc(this);
	wxCoord w, h;
	dc.GetSize(&w, &h);
	
	NSRect bb = [filter getBoundingBox];

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
	}else if (host){
		this->highlightHost (host);
	}
/*	//Selection of states for one-state representation disabled
	if (evt.LeftDown()){
		long x = evt.GetX();
		long y = evt.GetY();
		SimGrid *node = [current searchWithX: x
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

void SimGridDraw::OnKeyDownEvent(wxKeyEvent& evt)
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
//			this->drawSimGrid ((id)current, dc);
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
void SimGridDraw::highlightSimGridNode (long x, long y)
{
        if (current){
                id node = [current searchWithX: x
                                andY: y
                                limitToDepth: maxDepthToDraw];
                if (node != highlighted){
                        wxPaintDC dc(this);
                        this->unhighlightSimGridNode(dc);
                        this->drawHighlightSimGridNode (node, dc);
                        highlighted = node;
                }
        }
}

void SimGridDraw::unhighlightSimGridNode (wxDC &dc)
{
        wxColour grayColor = wxColour (wxT("#c0c0c0"));
        wxColour color;
        wxBrush brush;

        id parent = [[highlighted parent] parent];
        while (parent){
                color = this->findColorForNode (parent);
		brush = wxBrush (color, wxTRANSPARENT);
                this->drawSimGridNode (parent, 0, brush, grayColor, dc);
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
        	this->drawSimGridNode (agg, 0, brush, grayColor, dc);
	}
}

void SimGridDraw::drawHighlightSimGridNode (id node, wxDC &dc)
{
        wxColour blackColor = wxColour (wxT("#000000"));
        wxColour color = this->findColorForNode (node);
        wxBrush brush (color, wxTRANSPARENT);
        this->drawSimGridNode (node, 1, brush, blackColor, dc);

        NSMutableString *message;
        message = [NSMutableString stringWithFormat: @"%.3f - %@",
                                [node val], [node name]];
        id parent = [node parent];
        while (parent){
                color = this->findColorForNode (parent);
                this->drawSimGridNode (parent, 0, brush, blackColor, dc);
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

void SimGridDraw::drawSimGridNode (id node, int offset,
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

wxColour SimGridDraw::findColorForNode (id treemap)
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

void SimGridDraw::drawSimGrid (id treemap, wxDC &dc)
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
			this->drawSimGridNode (child, 0, brush, grayColor, dc);
		}
		
	}else{
		//recurse
		unsigned int i;
		for (i = 0; i < [[treemap children] count]; i++){
			this->drawSimGrid ([[treemap children]
				objectAtIndex: i], dc);
		}
	}
}
*/

void SimGridDraw::definePlatform()
{
	if (hosts) [hosts release];
	if (links) [links release];
	[hosts = [filter getHosts] retain];
	[links = [filter getLinks] retain];;
	if (!hosts || !links) return;
}
