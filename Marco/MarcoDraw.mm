#include "MarcoDraw.h"
#include <wx/dcps.h>
#include <wx/paper.h>
#include <float.h>
#include <gvc.h>

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);

IMPLEMENT_CLASS( MarcoDraw, wxControl )
BEGIN_EVENT_TABLE( MarcoDraw, wxControl )
        EVT_MOUSE_EVENTS( MarcoDraw::OnMouseEvent )
        EVT_KEY_DOWN( MarcoDraw::OnKeyDownEvent )
        EVT_PAINT( MarcoDraw::OnPaint )
        EVT_SIZE( MarcoDraw::OnSize )
//        EVT_CHAR( MarcoDraw::OnCharEvent )
//        EVT_KEY_UP( MarcoDraw::OnKeyUpEvent )
//        EVT_MOUSE_CAPTURE_LOST( MarcoDraw::OnMouseCapureLost )
END_EVENT_TABLE ()


MarcoDraw::MarcoDraw (wxWindow *parent, wxWindowID id,
	const wxPoint &pos, const wxSize &size, long style,
	const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);

	gvc = gvContext();
	resGraph = agopen ((char *)"MarcoGraph", AGRAPHSTRICT);

}

void MarcoDraw::OnPaint(wxPaintEvent& evt)
{
	NSLog (@"%s IN", __FUNCTION__);
	wxPaintDC dc(this);
	dc.Clear();
	{
		NSString *slice = [NSString stringWithFormat: @"%@ - %@",
			[filter selectionStartTime],
			[filter selectionEndTime]];
		dc.DrawText (NSSTRINGtoWXSTRING(slice), 0, 0);
	}
	static int flag = 1;
	if (flag){
	 gvFreeLayout (gvc, resGraph);
	 gvLayout (gvc, resGraph, (char*)"neato");
	 gvRenderFilename (gvc, resGraph, (char*)"png", (char*)"out.png");
	 gvRenderFilename (gvc, resGraph, (char*)"dot", (char*)"out.dot");
	 flag=0;
	}
	this->drawPlatform (dc);
	this->drawApplication (dc);
	NSLog (@"%s OUT", __FUNCTION__);
}

void MarcoDraw::drawApplication (wxDC &dc)
{

}

void MarcoDraw::drawPlatform (wxDC &dc)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	dc.SetPen(wxPen(wxT("Black"), 1, wxSOLID));
	dc.SetBrush(wxBrush(wxT("Black"), wxTRANSPARENT));
	wxCoord w, h;
	dc.GetSize(&w, &h);
	wxSize ppi = dc.GetPPI();
	double width = (double)w/72;
	double height = (double)h/72;

//	char ssize[100];
//	snprintf (ssize, 100, "%lf,%lf", width, height);
//	agraphattr(resGraph, (char*)"size", ssize);
//	agraphattr(resGraph, (char*)"bb", ssize);
//	agset (resGraph, (char*)"size", ssize);

	NSEnumerator *en;
	id route;

	static int flag = 1;
	if (flag){
		gvFreeLayout (gvc, resGraph);
		gvLayout (gvc, resGraph, (char*)"neato");
		flag=0;
	}

        /* draw platform */
	en = [routes objectEnumerator];
	while ((route = [en nextObject]) != nil){
		char *so = (char *)[[[route sourceContainer] name] cString];
		char *de = (char *)[[[route destContainer] name] cString];
		Agnode_t *nodes = agfindnode (resGraph, so);
		Agnode_t *noded = agfindnode (resGraph, de);
		float e = 0;
		if (nodes && noded && e <= 1) { /*<=1 to avoid draw loopback*/
			int x1 = (double)ND_coord_i(nodes).x/
				     GD_bb(resGraph).UR.x*w;
			int y1 = h-(double)ND_coord_i(nodes).y/
				     GD_bb(resGraph).UR.y*h;
			int x2 = (double)ND_coord_i(noded).x/
				     GD_bb(resGraph).UR.x*w;
			int y2 = h-(double)ND_coord_i(noded).y/
					GD_bb(resGraph).UR.y*h;
			dc.DrawLine (x1,y1,x2,y2);
			continue;
/*
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
*/
		}
	}

	/* draw link utilization 
	en = [[filter linksUtilization] objectEnumerator];
	id link;
	while ((link = [en nextObject])){
		char *so = (char *)[[[link sourceContainer] name] cString];
		char *de = (char *)[[[link destContainer] name] cString];
		Agnode_t *nodes = agfindnode (resGraph, so);
		Agnode_t *noded = agfindnode (resGraph, de);
		float b = [[link valueOfFieldNamed: @"Bandwidth"] floatValue];
		NSString *key = [[NSString alloc] initWithFormat: @"%@-%@",
			      [[link sourceContainer] name],
			      [[link destContainer] name]];
		[key release];
		float e = ((double)b-minBandwidth)/(maxBandwidth-minBandwidth);
	        //NSLog (@"%s=>%s %f (%f) %f", so, de, b, linkBW, e);
		if (nodes && noded && e <= 1) { //<=1 to avoid draw loopback
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
			//find color
			NSString *entityTypeName = [[link entityType] name];
			NSArray *aux2 = [entityTypeName componentsSeparatedByString: @"-"];
			NSString *cat = [aux2 objectAtIndex: 1];
			NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
			NSString *color = [d stringForKey:cat];
			if (color == nil){
			   NSLog (@"cat %@ not color defined, using Yellow", cat);
			   color = @"Yellow";
			}
			if ([cat isEqualToString: @"request"]) continue;
                        dc.SetPen(wxPen(wxT("Black"), 1, wxSOLID));
                        dc.SetBrush(wxBrush(NSSTRINGtoWXSTRING(color), wxSOLID));
			dc.DrawPolygon(4, points);
		}
	}
*/

      /* draw containers */
	en = [hosts objectEnumerator];
	id host;
	while ((host = [en nextObject]) != nil){
		char *name = (char *)[[host name] cString];
		Agnode_t *node = agfindnode (resGraph, name);
		if (node){
			int x = (double)ND_coord_i(node).x/
					GD_bb(resGraph).UR.x*w;
			int y = h-(double)ND_coord_i(node).y/
					GD_bb(resGraph).UR.y*h;
			//NSLog (@"%@ - %s %s", [host name],
			//	agget (node, (char*)"width"),
			//	agget (node, (char*)"height"));
			int nw = (int)(atof(agget (node, (char*)"width"))*72);
			int nh = (int)(atof(agget (node, (char*)"height"))*72);
			dc.SetBrush(wxBrush(wxT("White"), wxSOLID));
			if ([[[filter entityTypeForEntity: host] name]
					isEqualToString: @"processor"]){
				nw = nh = 10;
				dc.SetBrush(wxBrush(wxT("Red"), wxSOLID));
				dc.DrawRectangle (x-nw/2, y-nh/2, nw, nh);
			}else if ([[[filter entityTypeForEntity: host] name]
					isEqualToString: @"switch"]){
				nw = nh = 5;
				dc.SetBrush(wxBrush(wxT("Yellow"), wxSOLID));
				dc.DrawRectangle (x-nw/2, y-nh/2, nw, nh);
			}else if ([[[filter entityTypeForEntity: host] name]
					isEqualToString: @"cacheL2"]){
				dc.DrawRectangle (x-nw/2, y-nh/2, nw, nh);
			}
			//dc.SetPen(wxPen(wxT("Blue"), 1, wxSOLID));
		}
	}
	[pool release];
}

void MarcoDraw::OnSize (wxSizeEvent& evt)
{
	Refresh();
}

void MarcoDraw::OnMouseEvent(wxMouseEvent& evt)
{
	this->SetFocus();

/*	//Selection of states for one-state representation disabled
	if (evt.LeftDown()){
		long x = evt.GetX();
		long y = evt.GetY();
		Marco *node = [current searchWithX: x
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

void MarcoDraw::OnKeyDownEvent(wxKeyEvent& evt)
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
//			this->drawMarco ((id)current, dc);
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
void MarcoDraw::highlightMarcoNode (long x, long y)
{
        if (current){
                id node = [current searchWithX: x
                                andY: y
                                limitToDepth: maxDepthToDraw];
                if (node != highlighted){
                        wxPaintDC dc(this);
                        this->unhighlightMarcoNode(dc);
                        this->drawHighlightMarcoNode (node, dc);
                        highlighted = node;
                }
        }
}

void MarcoDraw::unhighlightMarcoNode (wxDC &dc)
{
        wxColour grayColor = wxColour (wxT("#c0c0c0"));
        wxColour color;
        wxBrush brush;

        id parent = [[highlighted parent] parent];
        while (parent){
                color = this->findColorForNode (parent);
		brush = wxBrush (color, wxTRANSPARENT);
                this->drawMarcoNode (parent, 0, brush, grayColor, dc);
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
        	this->drawMarcoNode (agg, 0, brush, grayColor, dc);
	}
}

void MarcoDraw::drawHighlightMarcoNode (id node, wxDC &dc)
{
        wxColour blackColor = wxColour (wxT("#000000"));
        wxColour color = this->findColorForNode (node);
        wxBrush brush (color, wxTRANSPARENT);
        this->drawMarcoNode (node, 1, brush, blackColor, dc);

        NSMutableString *message;
        message = [NSMutableString stringWithFormat: @"%.3f - %@",
                                [node val], [node name]];
        id parent = [node parent];
        while (parent){
                color = this->findColorForNode (parent);
                this->drawMarcoNode (parent, 0, brush, blackColor, dc);
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

void MarcoDraw::drawMarcoNode (id node, int offset,
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

wxColour MarcoDraw::findColorForNode (id treemap)
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

void MarcoDraw::drawMarco (id treemap, wxDC &dc)
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
			this->drawMarcoNode (child, 0, brush, grayColor, dc);
		}
		
	}else{
		//recurse
		unsigned int i;
		for (i = 0; i < [[treemap children] count]; i++){
			this->drawMarco ([[treemap children]
				objectAtIndex: i], dc);
		}
	}
}
*/

void MarcoDraw::recreateResourcesGraph()
{
	if (![filter checkForMarcoHierarchy]){
	        NSLog (@"It is not a Marco trace file");
		return;
	}

	agclose (resGraph);
	resGraph = agopen ((char *)"MarcoGraph", AGRAPHSTRICT);
	agnodeattr (resGraph, (char*)"label", (char*)"");
//	agraphattr (resGraph, (char*)"pad", (char*)"0.2");
//	agnodeattr (resGraph, (char*)"width", (char*)"1");
//	agnodeattr (resGraph, (char*)"height", (char*)"1");
//	agnodeattr (resGraph, (char*)"fixedsize", (char*)"true");
//	agnodeattr (resGraph, (char*)"nodesep", (char*)"2");
//	agnodeattr (resGraph, (char*)"overlap", (char*)"false");

	[hosts = [filter findContainersAt: [filter rootInstance]] retain];
	[routes = [filter findLinksAt: [filter rootInstance]] retain];

	/* creating nodes */
	NSEnumerator *en = [hosts objectEnumerator];
	id host;
	while ((host = [en nextObject]) != nil){
		Agnode_t *n = agnode (resGraph, (char *)[[host name] cString]);
                agsafeset (n, (char*)"width", (char*)"0.2", "1");
                agsafeset (n, (char*)"height", (char*)"0.2", "1");
                agsafeset (n, (char*)"style", (char*)"filled", "filled");
		if ([[[filter entityTypeForEntity: host] name]
				isEqualToString: @"processor"]){
                	agsafeset (n, (char*)"color", (char*)"red", "white");
			agsafeset (n, (char*)"shape",
				(char*)"circle",(char*)"rectangle");
		}else if ([[[filter entityTypeForEntity: host] name]
				isEqualToString: @"switch"]){
                	agsafeset (n, (char*)"color", (char*)"yellow", "white");
			agsafeset (n, (char*)"shape",
				(char*)"circle",(char*)"rectangle");
		}else if ([[[filter entityTypeForEntity: host] name]
				isEqualToString: @"cacheL2"]){
                	agsafeset (n, (char*)"color", (char*)"black", "black");
                	agsafeset (n, (char*)"style", (char*)"solid", "filled");
			agsafeset (n, (char*)"shape",
				(char*)"rectangle",(char*)"rectangle");
		}
	}

	/* creating edges */
	en = [routes objectEnumerator];
	id route;
	while ((route = [en nextObject]) != nil){
		Agnode_t *s, *d;
		s = agfindnode (resGraph,
			(char *)[[[route sourceContainer] name] cString]);
		d = agfindnode (resGraph,
			(char *)[[[route destContainer] name] cString]);
		Agedge_t *e = agedge (resGraph, s, d);
	}
}
