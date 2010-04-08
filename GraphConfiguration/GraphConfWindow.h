#ifndef __GraphConfWindow__
#define __GraphConfWindow__

#include "GraphConfWindowAuto.h"
#include <Triva/TrivaFilter.h>

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
extern NSString *WXSTRINGtoNSSTRING (wxString wsa);
extern std::string WXSTRINGtoSTDSTRING (wxString wsa);

class GraphConfWindow : public GraphConfWindowAuto
{
	private:
		id filter;

	public:
		GraphConfWindow (wxWindow *parent);
		void setController (id contr) { filter = contr; };

	protected:
		void addNewConfigurationPanel( wxCommandEvent& event );
		void applyCurrentConfiguration( wxCommandEvent& event );
		void loadFile( wxFileDirPickerEvent& event );
};

#endif
