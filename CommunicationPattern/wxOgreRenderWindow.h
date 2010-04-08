/////////////////////////////////////////////////////////////////////////////
// Name:      wxOgreRenderWindow.h
// Purpose:   wxWidgets Ogre render window widget
// Author:    Jesus Alonso Abad 'Kencho', 'mehdix', Other contributors (original wxOgre).
// Created:   1/12/2007
// RCS-ID:   
// Copyright:
// Licence:   
/////////////////////////////////////////////////////////////////////////////

#ifndef __WXOGRERENDERWINDOW_H__
#define __WXOGRERENDERWINDOW_H__

#include <Ogre.h>
#include "wx/wxprec.h"
#include "wx/wx.h"
#include "wx/xrc/xmlres.h"
#include "wxInputEventListener.h"


//////////////////////////////////////////////////////////////////////////////
/// wxWidgets Ogre render window widget.
/// Strongly based on the existing wxOgre widget implementation, this one
///   isolates the wx component from Ogre, acting as a simple bind to render
///   inside a wxWidgets window.
///
/// @note FIXME: Not thread-safe if Oger is executed in another thread.
///
/// @note Just the specified functions are (and should be) thread-safe.
///
///   @author Jesus Alonso Abad 'Kencho', 'mehdix', Other contributors (original wxOgre).
//////////////////////////////////////////////////////////////////////////////
class wxOgreRenderWindow : public wxControl
{
   DECLARE_CLASS( wxOgreRenderWindow )
   DECLARE_EVENT_TABLE()
   DECLARE_NO_COPY_CLASS( wxOgreRenderWindow )

public:
   /**
   * Default constructor.
   * Allows the "standard" wxWidgets' two-step construction.
   ****************************************************************/
   wxOgreRenderWindow();
   /**
   * wx-like Constructor.
   ****************************************************************/
   wxOgreRenderWindow(wxWindow *parent, wxWindowID id,
                  const wxPoint &pos = wxDefaultPosition,
                  const wxSize &size = wxDefaultSize,
                  long style = wxSUNKEN_BORDER,
                  const wxValidator &validator = wxDefaultValidator);
   /**
   * Creation method (for the two-step construction).
   ****************************************************************/
   bool Create(wxWindow *parent, wxWindowID id,
            const wxPoint &pos = wxDefaultPosition,
            const wxSize &size = wxDefaultSize,
            long style = wxSUNKEN_BORDER,
            const wxValidator &validator = wxDefaultValidator);
   /**
   * Virtual destructor.
   * @note Ogre's render window is Not destroyed here. It should already be
   *   destroyed either through Ogre and/or render system shutdown, or by
   *   calling destroyRenderWindow explicitly.
   ****************************************************************/
   virtual ~wxOgreRenderWindow();
   /**
   * Initialisation method.
   ****************************************************************/
   virtual void Init();
   /**
   * Updating function.
   * @note wxWidgets naming is used as this is an Inherited virtual function!
   * @note This function is thread-safe.
   ****************************************************************/
   virtual void Update();
   /**
   * Overrides the default implementation. This is here for convenience.
   * @return A size of 320x240 (just a symbolic 4:3 size).
   ****************************************************************/
   virtual wxSize DoGetBestSize() const { return wxSize(320, 240); }
   /**
   * Creates an Ogre render window for this widget.
   * @note Ogre::Root must have been created already!
   * @note This function is thread-safe.
   * @return The created render window.
   ****************************************************************/
   virtual Ogre::RenderWindow* createRenderWindow(
      const Ogre::NameValuePairList* miscParams = 0,
      const Ogre::String& windowName = Ogre::String(""));
   /**
   * Destroys the previously created Ogre render window for this widget.
   * @remarks This function allows explicit render window destruction.
   * @note This function is thread-safe.
   ****************************************************************/
   virtual void destroyRenderWindow();
   /**
   * Gets the associated Ogre render window.
   * @return The render window used to paint this control.
   ****************************************************************/
   Ogre::RenderWindow* getRenderWindow() const { return mRenderWindow; }
   /**
   * Sets the render timer period. Timer is created on demand.
   * @note Do Not start the timer when nothing exists to render and
   *   Root::renderOneFrame is called on timer events.
   *   (i.e. callRenderFrameOnTimer is called with true parameter).
   * @note This function is thread-safe.
   * @param period The number of milliseconds before the next notification.
   *   A negative or zero value stops the timer.
   * @param startNow If set to true, timer starts immediately.
   ****************************************************************/
   void setRenderTimerPeriod(int period, bool startNow = false);
   /**
   * Stop the timer.
   * @note This function is thread-safe.
   ****************************************************************/
   void pauseRenderTimer();
   /**
   * Restarts the previously stopped timer.
   * @note This function is thread-safe.
   ****************************************************************/
   void resumeRenderTimer();
   /**
   * Sets whether timer event, refreshes all the render targets and raising
   * frame events before and after, or just updates this target without
   * calling back any registered Ogre::frameListener classes. Default is False.
   * @param renderFrameInsteadUpdate If set to true, Root::renderOneFrame
   *   is called on render timer events, otherwise RenderWindow::update
   *   is used.
   ****************************************************************/
   void callRenderFrameOnTimer(bool renderFrameInsteadUpdate)
   {
      mCallRenderFrameOnTimer = renderFrameInsteadUpdate;
   }
   /**
   * Registers an input events listener which will be called back on input
   * events.
   * @note This function is thread-safe.
   ****************************************************************/
   void addInputListener(wxInputEventListener* listener);
   /**
   * Removes an input events listener from the list of listening classes.
   * @note This function is thread-safe.
   ****************************************************************/
   void removeInputListener(const wxInputEventListener* listener);
   /**
   * Sets whether registered listeners will be called back on events or not.
   * Default is True.
   * @note This function is thread-safe; it adds pending event that will be
   *   processed sometime later and returns immediately.
   * @param enabled If true, callback functions will be called on events. if
   *   false, no callback is called on events any more And releases mouse
   *   input if it had been captured by this window.
   * @param captureInput If true, sets the focus to this window and directs
   *   all mouse input to it. The main GUI window should be maximized to
   *   appear exclusive-access.
   ****************************************************************/
   void setListenersEnabled(bool enabled, bool captureInput = false);
   /**
   * Returns whether registered listeners will be called back on events.
   ****************************************************************/
   bool getListenersEnabled() const { return mListenersEnabled; }
   /**
   * Internal method for locking the access to the GUI lib.
   * @remarks If the caller is any thread other than the main GUI thread,
   *   blocks the execution of it until the main thread (or any other thread
   *   holding the main GUI lock) leaves the GUI library.
   * @note _leaveMainThreadMutex must be called after.
   ****************************************************************/
   void _enterMainThreadMutex(void) const
   {
      if (!wxIsMainThread())
         wxMutexGuiEnter();
   }
   /**
   * Internal method for unlocking the access to the GUI lib.
   * @remarks Releases the main GUI lock if the caller is not the main thread.
   * @note _enterMainThreadMutex must be called before.
   ****************************************************************/
   void _leaveMainThreadMutex(void) const
   {
      if (!wxIsMainThread())
         wxMutexGuiLeave();
   }

protected:
   /**
   * Resizing events callback.
   * @note The aspect ratio of each camera that is connected to this render
   *   target is also adjusted. Therefore make special attention to the
   *   cameras that are connected to other render targets at the same time.
   * @note This function is NOT thread-safe.  #-o
   ****************************************************************/
   virtual void OnSize(wxSizeEvent& evt);
   /**
   * Mouse events callback.
   ****************************************************************/
   virtual void OnMouseEvent(wxMouseEvent& evt);
   /**
   * This event is sent to a window that obtained mouse capture (using
   * CaptureMouse), which was subsequently loss due to "external" event
   * (e.g. another app captures the mouse).
   * @remarks Any application which captures the mouse in the beginning of
   *   some operation must handle this event and cancel this operation when
   *   it receives the event. The event handler must not recapture mouse.
   ****************************************************************/
   virtual void OnMouseCapureLost(wxMouseCaptureLostEvent& evt);
   /**
   * Character events callback.
   * @param evt Translated data contains the character event.
   *****************************************************************/
   virtual void OnCharEvent(wxKeyEvent& evt);
   /**
   * Key press events callback.
   * @note If a key down event is caught and the event handler does not call
   *   event.Skip(), then the corresponding character event will not happen.
   *   If you don't call event.Skip() for events that you don't process in
   *   key event function, shortcuts may cease to work on some platforms.
   * @param evt Untranslated data contains the key press event.
   ****************************************************************/
   virtual void OnKeyDownEvent(wxKeyEvent& evt);
   /**
   * Key release events callback.
   * @param evt Untranslated data contains the key release event.
   ****************************************************************/
   virtual void OnKeyUpEvent(wxKeyEvent& evt);
   /**
   * Render timer event callback.
   ****************************************************************/
   virtual void OnRenderTimer(wxTimerEvent& evt);
   /**
   * Painting event callback.
   ****************************************************************/
   virtual void OnPaint(wxPaintEvent& evt);
   /**
   * Gets the handle of the Ogre render window.
   * @return The render window handle.
   ****************************************************************/
   const Ogre::String _getOgreHandle() const;
   /**
   * Called by event loop to process the event that is posted by
   * setListenersEnabled.
   * @remarks Extra long member of the event, determines whether input should
   *   be captured or not.
   * @remarks This function must be executed in the context of the main/gui
   *   thread as mouse capturing APIs find the captured window in the current
   *   thread.
   ****************************************************************/
   void _setListenersEnabled(wxCommandEvent& event);

protected:

   /// The Id of the next render window.
   static unsigned int msNextRenderWindowId;

   /// This control's own render window reference.
   Ogre::RenderWindow *mRenderWindow;

   /// Timer to sync the rendering to a "constant" frame rate.
   wxTimer *mRenderTimer;

   int mRenderTimerPeriod;

   /// Specifies whether Root::renderOneFrame or RenderWindow::update will be
   /// called on render timer events.
   bool mCallRenderFrameOnTimer;

   bool mListenersEnabled;

   typedef std::vector<wxInputEventListener*> InputListenerList;
   InputListenerList mInputListeners;
};

#if wxUSE_XRC

//////////////////////////////////////////////////////////////////////////////
/// XML resource handler for wxOgreRenderWindow
///
///   @remarks To use the handler, it needs to be registered, as follows:
///      wxXmlResource::AddHandler( new wxOgreRenderWindowXmlHandler );
//////////////////////////////////////////////////////////////////////////////
class WXDLLIMPEXP_XRC wxOgreRenderWindowXmlHandler: public wxXmlResourceHandler
{
   DECLARE_DYNAMIC_CLASS( wxOgreRenderWindowXmlHandler )

public:
   wxOgreRenderWindowXmlHandler();

   virtual wxObject* DoCreateResource();

   virtual bool CanHandle(wxXmlNode* node);
};

#endif   // wxUSE_XRC

#endif   // __WXOGRERENDERWINDOW_H__ 
