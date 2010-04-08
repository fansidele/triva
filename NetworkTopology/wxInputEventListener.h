/////////////////////////////////////////////////////////////////////////////
// Name:      wxOgreRenderWindow.h
// Purpose:   wxWidgets Ogre render window widget
// Author:    Jesus Alonso Abad 'Kencho', 'mehdix', Other contributors (original wxOgre).
// Created:   1/12/2007
// RCS-ID:   
// Copyright:
// Licence:   
/////////////////////////////////////////////////////////////////////////////

#ifndef __WXINPUTEVENTLISTENER_H_
#define __WXINPUTEVENTLISTENER_H_

#include "wx/wxprec.h"
#include "wx/wx.h"
#include "wx/xrc/xmlres.h"


//////////////////////////////////////////////////////////////////////////////
/// Listener interface for mouse and keyboard events.
///
/// @remarks By calling event.Skip() in event handlers, event processing system
///      continues searching for a further handler function for the event.
///      Without event.Skip(), the event will not be processed any more. Note
///      that if multiple listeners are registered, the one registered LAST has
///      the final say.
/// @note In multi-threaded programs, functions of this callback interface are
///       called in the context of the main thread.
//////////////////////////////////////////////////////////////////////////////
class wxInputEventListener
{
public:
   /**
   * Character events callback.
   * @remarks Key down and up events are untranslated events, whereas
   *   character events are translated. The translated key is, in general,
   *   the character the user expects to appear as the result of the key
   *   combination when typing text into a text entry field.
   * @param evt Translated data regarding the character event.
   ****************************************************************/
   virtual void onCharEvent(wxKeyEvent& evt)      { evt.Skip(); }
   /**
   * Key press events callback.
   * @remarks Key down and up events are untranslated events, whereas
   *   character events are translated. The untranslated code for
   *   alphanumeric keys is always an uppercase value. For the other keys,
   *   it is one of the WXK_XXX values from the keycodes table.
   * @note If a key down event is caught and the event handler does not
   *   call event.Skip(), then the corresponding character event will not
   *   happen. If you don't call event.Skip() for events that you don't
   *   process in key event function, shortcuts may cease to work on some
   *   platforms.
   * @param evt Untranslated data regarding the key press event.
   ****************************************************************/
   virtual void onKeyDownEvent(wxKeyEvent& evt)   { evt.Skip(); }
   /**
   * Key release events callback.
   * @remarks Key down and up events are untranslated events, whereas
   *   character events are translated. The untranslated code for
   *   alphanumeric keys is always an uppercase value. For the other keys,
   *   it is one of the WXK_XXX values from the keycodes table.
   * @param evt Untranslated data regarding the key release event.
   ****************************************************************/
   virtual void onKeyUpEvent(wxKeyEvent& evt)      { evt.Skip(); }
   /**
   * Mouse events callback.
   * @remarks Called when any mouse event is generated.
   * @param evt Data related to the mouse event.
   ****************************************************************/
   virtual void onMouseEvent(wxMouseEvent& evt)   { evt.Skip(); }
   /**
   * Size events callback. Usefull for adjusting the mouse clipping extents.
   * @remarks Note that the size passed is of the whole window, in addition
   *   you might generate dummy size events with default size params (-1), to
   *   force the control to be adjusted for instance; so: call
   *   wxWindow::GetClientSize to get the area which may be used by the
   *   application.
   ****************************************************************/
   virtual void onWindowSize(wxSizeEvent& evt)      { evt.Skip(); }
   /**
   * This event is sent whenever listeners are disabled (ie they are not called
   * back any more through calling wxOgreRenderWindow::setListenersEnabled)
   * or obtained mouse capture is subsequently lost due to "external" event
   * (eg another app captures the mouse).
   * @remarks This event is usefull to clear the internal state of the
   *   listeners.
   ****************************************************************/
   virtual void onInputEventLost(void)            { }


   /**
    * This event is sent every time a frame is rendered.
    * We add this later to support animations in Triva. (Lucas,25aug2008)
    */
   virtual void onRenderTimer (wxTimerEvent& evt) { evt.Skip(); }
protected:
   virtual ~wxInputEventListener() {}
};

#endif
