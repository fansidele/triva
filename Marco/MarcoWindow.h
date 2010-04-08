#ifndef __MarcoWindow__
#define __MarcoWindow__

/**
@file
Subclass of MarcoWindowAuto, which is generated by wxFormBuilder.
*/

#include "MarcoWindowAuto.h"
#include "MarcoDraw.h"

/** Implementing MarcoWindowAuto */
class MarcoWindow : public MarcoWindowAuto
{
public:
	/** Constructor */
	MarcoWindow( wxWindow* parent );
        MarcoDraw *getDraw();
	void setStatusMessage (wxString message);
};

#endif // __MarcoWindow__