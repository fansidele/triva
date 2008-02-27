#ifndef __APPCONTROLLER_H
#define __APPOCONTROLLER_H

#include <wx/wxprec.h>
#include <wx/wx.h>
#include <Foundation/Foundation.h>
#include "view/TrivaController.h"
#include "core/OgreConfigure.h"

class ProtoController : public wxApp
{
	private:
		NSAutoreleasePool *pool;
		OgreConfigure *ogreConfigure;

	public:
		virtual bool OnInit();
		virtual int OnExit();
};

#endif
