#include "SliceDraw.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);

IMPLEMENT_CLASS( SliceDraw, wxControl )
BEGIN_EVENT_TABLE( SliceDraw, wxControl )
        EVT_PAINT( SliceDraw::OnPaint )
        EVT_SIZE( SliceDraw::OnSize )
END_EVENT_TABLE ()


SliceDraw::SliceDraw (wxWindow *parent, wxWindowID id,
	const wxPoint &pos, const wxSize &size, long style,
	const wxValidator &validator)
{
	Init();
	Create (parent, id, pos, size, style, validator);
}

void SliceDraw::OnPaint(wxPaintEvent& evt)
{
	wxPaintDC dc(this);
	wxCoord width, height;
	dc.GetSize(&width, &height);
	dc.Clear();

	double selStart, selEnd, end;

	selStart = [[[filter selectionStartTime] description] doubleValue];
	selEnd = [[[filter selectionEndTime] description] doubleValue];


	end = [[[filter endTime] description] doubleValue];

	int startp = (int)((selStart * (double)width) / end);
	int endp = (int)((selEnd * (double)width) / end);

	dc.SetPen (*wxBLACK_PEN);
	dc.DrawRectangle (0, 0, width, height);
	dc.SetPen (*wxTRANSPARENT_PEN);

	dc.SetBrush (*wxGREY_BRUSH);
	dc.DrawRectangle (startp+1, 1, endp-startp-2, height-2);
}

void SliceDraw::OnSize (wxSizeEvent& evt)
{
	Refresh();
}
