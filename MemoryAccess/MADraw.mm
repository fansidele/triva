/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "MADraw.h"
#include <wx/dcps.h>
#include <wx/paper.h>

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);

IMPLEMENT_CLASS( MADraw, wxControl )
BEGIN_EVENT_TABLE( MADraw, wxControl )
        EVT_MOUSE_EVENTS( MADraw::OnMouseEvent )
        EVT_KEY_DOWN( MADraw::OnKeyDownEvent )
        EVT_PAINT( MADraw::OnPaint )
        EVT_SIZE( MADraw::OnSize )
//        EVT_CHAR( MADraw::OnCharEvent )
//        EVT_KEY_UP( MADraw::OnKeyUpEvent )
//        EVT_MOUSE_CAPTURE_LOST( MADraw::OnMouseCapureLost )
END_EVENT_TABLE ()


MADraw::MADraw (wxWindow *parent, wxWindowID id,
	const wxPoint &pos, const wxSize &size, long style,
	const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);
}

void MADraw::drawCPUandThreads (wxDC &dc)
{
	
}

void MADraw::drawMemory (wxDC &dc)
{

}

void MADraw::drawRect (wxString name, MARect *rect, wxDC &dc)
{
	int offset = 0;
	int x = [rect x];
	int y = [rect y];
	int w = [rect width];
	int h = [rect height];
//	std::cout << "Drawing .. " << WXSTRINGtoSTDSTRING(name)
//		<< " " << x
//		<< " " << y
//		<< " " << w
//		<< " " << h
//		<< std::endl;

	wxPoint points[5];
	points[0] = wxPoint (x+offset,y+offset);
	points[1] = wxPoint (x+w-offset, y+offset);
	points[2] = wxPoint (x+w-offset, y+h-offset);
	points[3] = wxPoint (x+offset, y+h-offset);
	points[4] = wxPoint (x+offset,y+offset);

	/* draw rectangle */
	dc.DrawPolygon (5, points);

	/* draw name */
	//wxCoord w1, h1;
	//dc.GetTextExtent (name, &w1, &h1);
	dc.DrawText (name, x, y);
}

void MADraw::OnPaint(wxPaintEvent& evt)
{
        wxPaintDC dc(this);
	dc.Clear();
        wxCoord width, height;
        dc.GetSize(&width, &height);

	/* draw structure */
	std::cout << std::endl;
	id globalLayout = [filter layoutWithWidth: width andHeight: height];
	NSDictionary *layout = [globalLayout layout];
	NSEnumerator *en = [layout keyEnumerator];
	id name;
	while ((name = [en nextObject])){
		if (![name isEqualToString: @"CPU-SIMICS"]){
			this->drawRect (NSSTRINGtoWXSTRING(name), 
				(MARect *)[layout objectForKey: name], dc);
		}
	}

	/* draw timestamped memory accesses */	
	PajeEntityType *cpu = [filter entityTypeWithName: @"CPU"];
        PajeEntityType *thread = [filter entityTypeWithName: @"THREAD"];
        NSEnumerator *en1 = [filter enumeratorOfContainersTyped: cpu
                                inContainer: [filter rootInstance]];
        id cpuEnt;
        while ((cpuEnt = [en1 nextObject])){
                NSEnumerator *en2 = [filter enumeratorOfContainersTyped: thread
                                        inContainer: cpuEnt];
                id threadEnt;
                while ((threadEnt = [en2 nextObject])){
                        PajeEntityType *et;
                        NSEnumerator *en3;
			et = [filter entityTypeWithName: @"ACCESS"];
			en3 = [filter enumeratorOfEntitiesTyped: et
                                        inContainer:  threadEnt
                                        fromTime: [filter startTime]
                                        toTime: [filter endTime]
                                        minDuration: 0.1];
                        id ent;
                        while ((ent = [en3 nextObject])){
				MARect *cont = [layout objectForKey:
					[threadEnt name]];
				int ox = [cont x]+[cont width];
				int oy = [cont y]+[cont height]/2;

				double val = atof([[filter valueOfFieldNamed:
					@"VirtualMemory" forEntity: ent]
						cString]);

				int dx = width*.9;
				int dy;
				NSDictionary *d = [globalLayout findMemoryWindowForValue: val];
				if (d){
					double dif = [[d objectForKey: @"dif"] doubleValue];
					double start = [[d objectForKey: @"start"] doubleValue];
					MARect *mem = (MARect *)[d objectForKey: @"rect"];

//					NSLog (@"%f -> %@", val, d);
					dy = [mem y]+[mem height]/dif*(val-start);

					/* find color */
					wxColour color = this->findColorForEntity(ent);
					dc.SetPen (wxPen(color,1, wxSOLID));
					dc.DrawLine (ox, oy, dx, dy);
				}

			}
		}
	}



/*


	wxPaintDC dc(this);

	dc.Clean();

	this->drawCPUandThreads (&dc);
	this->drawMemory (&dc);

	PajeEntityType *et;
	NSEnumerator *en;
	en = [[filter containedTypesForContainerType:[filter entityTypeForEntity:instance]] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		NSLog(@"t%*.*s%@", level+1, level+1, "", [filter descriptionForEntityType:et]);
		if ([filter isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [filter enumeratorOfContainersTyped:et inContainer:instance];
			while ((sub = [en2 nextObject]) != nil) {
		//		[filter printInstance:sub level:level+2];
			}
		} else {
			NSEnumerator *en3;
			PajeEntity *ent;
			en3 = [filter enumeratorOfEntitiesTyped:et
                                      inContainer:instance
                                         fromTime:[filter startTime]
                                           toTime:[filter endTime]
                                      minDuration:0.01];
			while ((ent = [en3 nextObject]) != nil) {
				NSLog(@"e%*.*s%@", level+2, level+2, "", [filter descriptionForEntity:ent]);
			}
		}
	}
}
*/
/*
	wxPaintDC dc(this);
	wxCoord width, height;
	dc.GetSize(&width, &height);
	current = [filter treemapWithWidth: width andHeight: height
			andDepth: 0 andValues: [NSSet set]];
	dc.Clear();
	this->drawTreemap ((id)current, dc);
*/
}

void MADraw::OnSize (wxSizeEvent& evt)
{
	Refresh();
}

void MADraw::OnMouseEvent(wxMouseEvent& evt)
{
/*
	this->highlightTreemapNode (evt.GetX(), evt.GetY());
	this->SetFocus();

	//Selection of states for one-state representation disabled
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

void MADraw::OnKeyDownEvent(wxKeyEvent& evt)
{
/*
	if (evt.AltDown() && evt.GetKeyCode() == 80) { // ALT + P 
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
*/
}


/*
 * The following methods are always called by previous methods in this file
 */
wxColour MADraw::findColorForEntity (id entity)
{
        wxColour color;
        if (filter && ![filter isContainerEntityType: [entity entityType]]) {
                NSColor *c = [filter colorForValue: [entity name]
                        ofEntityType: (PajeEntityType *)[entity entityType]];
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
