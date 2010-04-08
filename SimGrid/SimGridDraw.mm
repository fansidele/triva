#include "SimGridDraw.h"
#include <wx/dcps.h>
#include <wx/paper.h>
#include <float.h>
#include <gvc.h>

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


SimGridDraw::SimGridDraw (wxWindow *parent, wxWindowID id,
	const wxPoint &pos, const wxSize &size, long style,
	const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);

	gvc = gvContext();
	resGraph = NULL;//agopen ((char *)"SimGridGraph", AGRAPHSTRICT);

}

void SimGridDraw::OnPaint(wxPaintEvent& evt)
{
//	NSLog (@"%s", __FUNCTION__);
	wxPaintDC dc(this);
	dc.Clear();
	dc.SetPen(wxPen(wxT("Black"), 1, wxSOLID));
	dc.SetBrush(wxBrush(wxT("Black"), wxTRANSPARENT));
	wxCoord w, h;
	dc.GetSize(&w, &h);
	w-=30;
	h-=30;
	wxSize ppi = dc.GetPPI();
	double width = (double)w/96;
	double height = (double)h/96;


	char ssize[100];
	snprintf (ssize, 100, "%lf,%lf", width, height);
//	agraphattr(resGraph, (char*)"size", ssize);
//	agraphattr(resGraph, (char*)"bb", ssize);
//	agset (resGraph, (char*)"size", ssize);

	NSEnumerator *en;
	id route;

	static int flag = 1;
	if (flag){
		gvFreeLayout (gvc, resGraph);
		gvLayout (gvc, resGraph, (char*)"twopi");
		flag=0;
	}
	gvRenderFilename (gvc, resGraph, (char*)"png", (char*)"out.png");
	gvRenderFilename (gvc, resGraph, (char*)"dot", (char*)"out.dot");


	en = [routes objectEnumerator];
	while ((route = [en nextObject]) != nil){
		char *so = (char *)[[[route sourceContainer] name] cString];
		char *de = (char *)[[[route destContainer] name] cString];
		Agnode_t *nodes = agfindnode (resGraph, so);
		Agnode_t *noded = agfindnode (resGraph, de);
		float b = [[route valueOfFieldNamed: @"Bandwidth"] floatValue];
		float e = ((double)b-minBandwidth)/(maxBandwidth-minBandwidth);
		if (nodes && noded && e <= 1) { /*<=1 to avoid draw loopback*/
			int x1 = 15+(double)ND_coord_i(nodes).x/
					GD_bb(resGraph).UR.x*w;
			int y1 = 15+h-(double)ND_coord_i(nodes).y/
					GD_bb(resGraph).UR.y*h;
			int x2 = 15+(double)ND_coord_i(noded).x/
					GD_bb(resGraph).UR.x*w;
			int y2 = 15+h-(double)ND_coord_i(noded).y/
					GD_bb(resGraph).UR.y*h;

			e = 10+e*10;
	
			int ox1,oy1;
			int ox2,oy2;
			int ox3,oy3;
			int ox4,oy4;

			float distance = sqrt (
					(x2*x2-2*x2*x1+x1*x1)+
					(y2*y2-2*y2*y1+y1*y1));
			float k = 10/distance;
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
			float aux = sqrt ((y2*y2-2*y2*y1+y1*y1)+
					(x2*x2-2*x2*x1+x1*x1));
			float top1 = e*y2-e*y1;
			float top2 = -e*x2+e*x1;
			ox1 = -top1/aux + x2;
			oy1 = -top2/aux + y2;
		
			ox2 = top1/aux + x2;
			oy2 = top2/aux + y2;
		
			ox3 = top1/aux + x1;
			oy3 = top2/aux + y1;

			ox4 = -top1/aux + x1;
			oy4 = -top2/aux + y1;
	
			wxPoint points[4];
			points[0] = wxPoint (ox1, oy1);
			points[1] = wxPoint (ox2, oy2);
			points[2] = wxPoint (ox3, oy3);
			points[3] = wxPoint (ox4, oy4);

//			NSLog (@"%d,%d - %d,%d - %d,%d - %d,%d",
//				ox1, oy1,
//				ox2, oy2,
//				ox3, oy3,
//				ox4, oy4);

			dc.DrawPolygon(4, points);
		}
	}


	en = [hosts objectEnumerator];
	id host;
	while ((host = [en nextObject]) != nil){
		char *name = (char *)[[host name] cString];
		Agnode_t *node = agfindnode (resGraph, name);
		if (node){
			int x = 15+(double)ND_coord_i(node).x/
					GD_bb(resGraph).UR.x*w;
			int y = 15+h-(double)ND_coord_i(node).y/
					GD_bb(resGraph).UR.y*h;
			int nw = (int)(atof(agget (node, (char*)"width"))*96);
			int nh = (int)(atof(agget (node, (char*)"height"))*96);
			dc.SetPen(wxPen(wxT("Blue"), 1, wxSOLID));
			dc.SetBrush(wxBrush(wxT("White"), wxSOLID));
			dc.DrawRectangle (x-nw/2, y-nh/2, nw, nh);
		}
	}
}

void SimGridDraw::OnSize (wxSizeEvent& evt)
{
	Refresh();
}

void SimGridDraw::OnMouseEvent(wxMouseEvent& evt)
{
	this->SetFocus();

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
	}else if (evt.AltDown() && evt.GetKeyCode() == 68) { /* ALT + D (to dump) */
		[filter dumpTraceInTextualFormat];
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

void SimGridDraw::recreateResourcesGraph()
{
	if (![filter checkForSimGridHierarchy:
			[[filter rootInstance] entityType] level: 0]){
		return;
	}

	agclose (resGraph);
	resGraph = agopen ((char *)"SimGridGraph", AGRAPHSTRICT);
	agraphattr (resGraph, (char*)"pad", (char*)"0.2");
	agnodeattr (resGraph, (char*)"width", (char*)"1");
	agnodeattr (resGraph, (char*)"height", (char*)"1");
	agnodeattr (resGraph, (char*)"fixedsize", (char*)"true");
	agnodeattr (resGraph, (char*)"label", (char*)"");

	[hosts = [filter findHostsAt: [filter rootInstance]] retain];
	[routes = [filter findRoutesAt: [filter rootInstance]] retain];

	/* creating nodes, searching for min/max powers */
	NSEnumerator *en = [hosts objectEnumerator];
	id host;
	maxPower = 0;
	minPower = FLT_MAX;
	while ((host = [en nextObject]) != nil){
		Agnode_t *n = agnode (resGraph, (char *)[[host name] cString]);
		agsafeset (n, (char*)"shape",
			(char*)"rectangle",(char*)"rectangle");
		int power = [[filter valueOfFieldNamed: @"Power"
						forEntity: host] intValue];
		if (power != 0){
			if (power > maxPower) maxPower = power;
			if (power < minPower) minPower = power;
		}
	}

	/* creating edges, searching for min/max bandwidth */
	en = [routes objectEnumerator];
	id route;
	minBandwidth = FLT_MAX;
	maxBandwidth = 0;
	while ((route = [en nextObject]) != nil){
		Agnode_t *s, *d;
		s = agfindnode (resGraph,
			(char *)[[[route sourceContainer] name] cString]);
		d = agfindnode (resGraph,
			(char *)[[[route destContainer] name] cString]);
		Agedge_t *e = agedge (resGraph, s, d);

		NSString *pol = [filter valueOfFieldNamed: @"SharingPolicy"
					forEntity: route];
		if (pol == nil){
			float bandwidth;
			bandwidth = [[filter valueOfFieldNamed: @"Bandwidth"
					forEntity: route] floatValue];
			if (bandwidth > maxBandwidth) maxBandwidth = bandwidth;
			if (bandwidth < minBandwidth) minBandwidth = bandwidth;
		}
	}

	/* defining nodes size based on powers */
	int dif = maxPower - minPower;
	en = [hosts objectEnumerator];
	while ((host = [en nextObject]) != nil){
		Agnode_t *n = agfindnode (resGraph,
				(char *)[[host name] cString]);
		int power = [[filter valueOfFieldNamed: @"Power"
						forEntity: host] intValue];
		if (power == 0){ //router
			agsafeset (n, (char*)"width", (char*)"0.1", "1");
			agsafeset (n, (char*)"height", (char*)"0.1", "1");
		}else{
			float s = 1+((double)power - minPower)/(double)dif;
			char nh[100];
			snprintf (nh,100,"%f", s);
			agsafeset (n, (char *)"height", (char *)nh, "1");
			agsafeset (n, (char *)"width", (char *)"0.4", "1");
		}
	}
	en  = [routes objectEnumerator];
	while ((route = [en nextObject]) != nil){
		Agnode_t *s, *d;
		s = agfindnode (resGraph,
			(char *)[[[route sourceContainer] name] cString]);
		d = agfindnode (resGraph,
			(char *)[[[route destContainer] name] cString]);
		Agedge_t *e = agfindedge (resGraph, s, d);
		NSString *pol = [filter valueOfFieldNamed: @"SharingPolicy"
					forEntity: route];
		if (pol == nil){
			float b;
			b = [[filter valueOfFieldNamed: @"Bandwidth"
					forEntity: route] floatValue];
			float s = ((double)b-minBandwidth)/
				(maxBandwidth-minBandwidth);
			char ns[100], nss[100];
			snprintf (ns, 100, "setlinewidth(%d)", (int)(10+20*s));	
			snprintf (nss, 100, "%.2f", s);	
			agsafeset (e, (char*)"style",
				(char*)ns,
				(char*)"setlinewidth(10)");
		}
	}
}
