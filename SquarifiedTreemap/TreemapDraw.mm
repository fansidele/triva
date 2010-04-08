#include "TreemapDraw.h"
#include <wx/dcps.h>
#include <wx/paper.h>

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);

IMPLEMENT_CLASS( TreemapDraw, wxControl )
BEGIN_EVENT_TABLE( TreemapDraw, wxControl )
        EVT_MOUSE_EVENTS( TreemapDraw::OnMouseEvent )
        EVT_KEY_DOWN( TreemapDraw::OnKeyDownEvent )
        EVT_PAINT( TreemapDraw::OnPaint )
        EVT_SIZE( TreemapDraw::OnSize )
//        EVT_CHAR( TreemapDraw::OnCharEvent )
//        EVT_KEY_UP( TreemapDraw::OnKeyUpEvent )
//        EVT_MOUSE_CAPTURE_LOST( TreemapDraw::OnMouseCapureLost )
END_EVENT_TABLE ()


TreemapDraw::TreemapDraw (wxWindow *parent, wxWindowID id,
	const wxPoint &pos, const wxSize &size, long style,
	const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);
	current = nil;
	highlighted = nil;
	maxDepthToDraw = 1;
	selectedValues = [[NSMutableArray alloc] init];
}

void TreemapDraw::OnPaint(wxPaintEvent& evt)
{
	wxPaintDC dc(this);
	wxCoord width, height;
	dc.GetSize(&width, &height);
	current = [filter treemapWithWidth: width andHeight: height
			andDepth: 0 andValues: selectedValues];
	dc.Clear();
	this->drawTreemap ((id)current, dc);
}

void TreemapDraw::OnSize (wxSizeEvent& evt)
{
	Refresh();
}

void TreemapDraw::OnMouseEvent(wxMouseEvent& evt)
{
	this->highlightTreemapNode (evt.GetX(), evt.GetY());
	this->SetFocus();

/*	//Selection of states for one-state representation disabled
	if (evt.LeftDown()){
		long x = evt.GetX();
		long y = evt.GetY();
		Treemap *node = [current searchWithX: x
		                andY: y
		                limitToDepth: maxDepthToDraw];
		[selectedValues addObject: [[node pajeEntity] value]];
		Update(true);
		return;
	}
*/
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
}

void TreemapDraw::OnKeyDownEvent(wxKeyEvent& evt)
{
	if (evt.AltDown() && evt.GetKeyCode() == 80) { /* ALT + P */
		wxClientDC screen(this);
	        wxCoord w, h;
	        screen.GetSize (&w, &h);
	        NSString *filename = [NSString stringWithFormat:
	                @"output-%d-%d-%d.ps", maxDepthToDraw, w, h];
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
			this->drawTreemap ((id)current, dc);
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
void TreemapDraw::highlightTreemapNode (long x, long y)
{
        if (current){
                id node = [current searchWithX: x
                                andY: y
                                limitToDepth: maxDepthToDraw
				andSelectedValues: selectedValues];
                if (node != highlighted){
                        wxPaintDC dc(this);
                        this->unhighlightTreemapNode(dc);
                        this->drawHighlightTreemapNode (node, dc);
                        highlighted = node;
                }
        }
}

void TreemapDraw::unhighlightTreemapNode (wxDC &dc)
{
        wxColour grayColor = wxColour (wxT("#c0c0c0"));
        wxColour color;
        wxBrush brush;

        id parent = [[highlighted parent] parent];
        while (parent){
                color = this->findColorForNode (parent);
		brush = wxBrush (color, wxTRANSPARENT);
                this->drawTreemapNode (parent, 0, brush, grayColor, dc);
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
        	this->drawTreemapNode (agg, 0, brush, grayColor, dc);
	}
}

/* Drawing related methods */
void TreemapDraw::drawHighlightTreemapNode (id node, wxDC &dc)
{
        wxColour blackColor = wxColour (wxT("#000000"));
        wxColour color = this->findColorForNode (node);
        wxBrush brush (color, wxTRANSPARENT);
        this->drawTreemapNode (node, 1, brush, blackColor, dc);

        /* setting message in the status bar and drawing parents */
        NSMutableString *message;
        message = [NSMutableString stringWithFormat: @"%.3f - %@",
                                [node val], [node name]];
        id parent = [node parent];
        while (parent){
                color = this->findColorForNode (parent);
                this->drawTreemapNode (parent, 0, brush, blackColor, dc);
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

void TreemapDraw::drawTreemapNode (id node, int offset,
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

wxColour TreemapDraw::findColorForNode (id treemap)
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

void TreemapDraw::drawTreemap (id treemap, wxDC &dc)
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
			this->drawTreemapNode (child, 0, brush, grayColor, dc);
		}
		
	}else{
		//recurse
		unsigned int i;
		for (i = 0; i < [[treemap children] count]; i++){
			this->drawTreemap ([[treemap children]
				objectAtIndex: i], dc);
		}
	}
}
