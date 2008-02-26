#ifndef __APPCONTROLLER_H
#define __APPOCONTROLLER_H

#include <wx/wxprec.h>
#include <wx/wx.h>
#include <Foundation/Foundation.h>
#include "core/TrivaController.h"

class ProtoController : public wxApp
{
	private:
		NSAutoreleasePool *pool;
	public:
		virtual bool OnInit();
};

#endif
