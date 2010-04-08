#ifndef __TreemapWindow__
#define __TreemapWindow__

/**
@file
Subclass of TreemapWindowAuto, which is generated by wxFormBuilder.
*/

#include "TreemapWindowAuto.h"
#include "TreemapDraw.h"

/** Implementing TreemapWindowAuto */
class TreemapWindow : public TreemapWindowAuto
{
public:
	/** Constructor */
	TreemapWindow( wxWindow* parent );
        TreemapDraw *getTreemapDraw();
	void setStatusMessage (wxString message);

};

#endif // __TreemapWindow__
