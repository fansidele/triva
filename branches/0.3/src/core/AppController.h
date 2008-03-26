#ifndef __APPCONTROLLER_H
#define __APPOCONTROLLER_H

#include <wx/wxprec.h>
#include <wx/wx.h>
#include <Foundation/Foundation.h>
#include "gui/TrivaController.h"
#include "core/OgreConfigure.h"

class ProtoController : public wxApp
{
	private:
		NSAutoreleasePool *pool;
		OgreConfigure *ogreConfigure;
		wxTimer nsRunloopTimer;
		void runGNUstepLoop(wxTimerEvent& event);

	public:
		virtual bool OnInit();
		virtual int OnExit();
};

#endif
