#ifndef __WXWIDGETSAPP_H
#define __WXWIDGETSAPP_H

#include <wx/wx.h>
#include <Foundation/Foundation.h>
#include <GNUstepBase/GSConfig.h>

class TrivaApp : public wxApp
{
private:
    wxTimer gnustepLoopTimer; 
    NSAutoreleasePool *pool;

public:
    bool OnInit();
    int OnExit();

protected:
    void runGNUstepLoop (wxTimerEvent& event);
};

DECLARE_APP(TrivaApp)

#endif 

