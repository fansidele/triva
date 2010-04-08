#ifndef __GraphConfPanel__
#define __GraphConfPanel__

#include "GraphConfWindowAuto.h"
#include <Triva/TrivaFilter.h>

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);

class GraphConfPanel : public GraphConfPanelAuto
{
	private:
		id filter;

	public:
		GraphConfPanel( wxWindow* parent, id contr, wxWindowID id = wxID_ANY, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,300 ), long style = wxTAB_TRAVERSAL );
		void setController (id contr) { filter = contr; };

	
};

#endif
