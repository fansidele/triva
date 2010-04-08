/////////////////////////////////////////////////////////////////////////////
// Name:      wxOgreRenderWindow.cpp
// Purpose:   wxWidgets Ogre render window widget
// Author:    Jesus Alonso Abad 'Kencho', 'mehdix', Other contributors (original wxOgre).
// Created:   1/12/2007
// Copyright:
// Licence:   
/////////////////////////////////////////////////////////////////////////////

#ifdef __BORLANDC__
    #pragma hdrstop
#endif

#include "wxOgreRenderWindow.h"
//#include "OgreNoMemoryMacros.h"
#if defined(__WXGTK__)
   // NOTE: Find the GTK install config with `pkg-config --cflags gtk+-2.0`
   #include "gtk/gtk.h"
   #include "gdk/gdk.h"
   #include "gdk/gdkx.h"
   #include "wx/gtk/win_gtk.h"
   #include "GL/glx.h"
#endif


//============================================================================
// wxWidgets Ogre render window widget.
//
//============================================================================

// Create a new event type to notify the application about de/activating listeners.

DECLARE_EVENT_TYPE( wxEVT_ENABLE_LISTENERS, -1 )

DEFINE_EVENT_TYPE( wxEVT_ENABLE_LISTENERS )

//----------------------------------------------------------------------------
const wxWindowID ID_RENDERTIMER = ::wxNewId();

//----------------------------------------------------------------------------

IMPLEMENT_CLASS( wxOgreRenderWindow, wxControl )

BEGIN_EVENT_TABLE( wxOgreRenderWindow, wxControl )

   EVT_SIZE( wxOgreRenderWindow::OnSize )

   EVT_MOUSE_EVENTS( wxOgreRenderWindow::OnMouseEvent )
   EVT_CHAR( wxOgreRenderWindow::OnCharEvent )
   EVT_KEY_DOWN( wxOgreRenderWindow::OnKeyDownEvent )
   EVT_KEY_UP( wxOgreRenderWindow::OnKeyUpEvent )

   EVT_TIMER( ID_RENDERTIMER, wxOgreRenderWindow::OnRenderTimer )
//#ifndef __WXMSW__
   EVT_PAINT( wxOgreRenderWindow::OnPaint )
//#endif
   EVT_MOUSE_CAPTURE_LOST( wxOgreRenderWindow::OnMouseCapureLost )
END_EVENT_TABLE ()

//----------------------------------------------------------------------------
unsigned int wxOgreRenderWindow::msNextRenderWindowId = 1;

//----------------------------------------------------------------------------
wxOgreRenderWindow::wxOgreRenderWindow()
{
   Init();
}
//----------------------------------------------------------------------------
wxOgreRenderWindow::wxOgreRenderWindow(wxWindow *parent, wxWindowID id,
   const wxPoint& pos, const wxSize& size, long style,
   const wxValidator& validator)
{
   Init();
   Create(parent, id, pos, size, style, validator);
}
//----------------------------------------------------------------------------
bool wxOgreRenderWindow::Create(wxWindow* parent, wxWindowID id,
   const wxPoint& pos,   const wxSize& size, long style,
   const wxValidator& validator)
{
	std::cout << __FILE__ << __FUNCTION__ << std::endl;
   if (!wxControl::Create(parent, id, pos, size, style, validator)){
		std::cout << "vou retornar falso" << std::endl;
      return false;
	}

	std::cout << "continuando" << std::endl;
   // Connect the Command event handler dynamically
   Connect(GetId(), wxEVT_ENABLE_LISTENERS,
      wxCommandEventHandler(wxOgreRenderWindow::_setListenersEnabled));
	std::cout << "retornando verdadeiro" << std::endl;

   return true;
}
//----------------------------------------------------------------------------
wxOgreRenderWindow::~wxOgreRenderWindow()
{
   delete mRenderTimer;
   mRenderTimer = 0;

   mRenderWindow = 0;      // NOTE: Must have been deleted already
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::Init ()
{
   mRenderWindow = 0;
   mRenderTimer = 0;
   mRenderTimerPeriod = 0;
   mCallRenderFrameOnTimer = true;
   mListenersEnabled = true;
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::Update()
{
   if (mRenderWindow)
   {
      // Ensure current iteration of the main gui loop is completed, so
      // there is no possiblity of any changes in window properties during
      // rendering (eg size).
      _enterMainThreadMutex();

      // FIXME: Thread-safty!
      mRenderWindow->update();      // swapBuffers=true ?

      _leaveMainThreadMutex();
   }
}
//----------------------------------------------------------------------------
Ogre::RenderWindow* wxOgreRenderWindow::createRenderWindow(
   const Ogre::NameValuePairList* miscParams, const Ogre::String& windowName)
{
	std::cout << __FUNCTION__ << std::endl;

//   wxASSERT(!mRenderWindow);

   _enterMainThreadMutex();

   // Background is not needed to be erased any more.
   SetBackgroundStyle(wxBG_STYLE_CUSTOM);

   Ogre::String name = windowName;
	std::cout << "windowName =  " << windowName << std::endl;
   if (windowName.empty())
      name = Ogre::String("wxOgreRenderWindow") +
            Ogre::StringConverter::toString(msNextRenderWindowId++);

	std::cout << "name =  " << name << std::endl;
   // Get wx control client size
   int width, height;
   GetClientSize(&width, &height);

	std::cout << "width,height = " << width << "," << height << std::endl;

   Ogre::NameValuePairList params;
   if (miscParams) {
      params = *miscParams;
   }
	std::cout << "## alll ---> " << _getOgreHandle() << std::endl;
   params["externalWindowHandle"] = _getOgreHandle();

	std::cout << "## alll" << std::endl;

   // Create the render window
   mRenderWindow = Ogre::Root::getSingleton().createRenderWindow(
         name, width, height, false, &params);

   mRenderWindow->setActive(true);

   _leaveMainThreadMutex();

   return mRenderWindow;
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::destroyRenderWindow()
{
   _enterMainThreadMutex();

   if (mRenderWindow)
      Ogre::Root::getSingleton().detachRenderTarget(mRenderWindow);

   mRenderWindow = 0;

   // Restore the default background style.
   SetBackgroundStyle(wxBG_STYLE_SYSTEM);

   _leaveMainThreadMutex();
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::setRenderTimerPeriod(int period, bool startNow)
{
   mRenderTimerPeriod = period;

   if (startNow)
      resumeRenderTimer();
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::pauseRenderTimer()
{
   if (mRenderTimer)
   {
      _enterMainThreadMutex();

      mRenderTimer->Stop();

      _leaveMainThreadMutex();
   }
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::resumeRenderTimer()
{
   _enterMainThreadMutex();

   if (mRenderTimer)
   {
      if (0 >= mRenderTimerPeriod)
         mRenderTimer->Stop();
      else
         mRenderTimer->Start(mRenderTimerPeriod);
   }
   // Create the timer when really needed
   else if (0 < mRenderTimerPeriod)
   {
      mRenderTimer = new wxTimer(this, ID_RENDERTIMER);
      mRenderTimer->Start(mRenderTimerPeriod);
   }

   _leaveMainThreadMutex();
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::addInputListener(wxInputEventListener* listener)
{
   _enterMainThreadMutex();

   mInputListeners.push_back(listener);

   _leaveMainThreadMutex();
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::removeInputListener(
   const wxInputEventListener* listener)
{
   _enterMainThreadMutex();

   for (InputListenerList::iterator iter = mInputListeners.begin();
      mInputListeners.end() != iter; ++iter)
   {
      if (listener == (*iter))
      {
         mInputListeners.erase(iter);
         break;
      }
   }

   _leaveMainThreadMutex();
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::setListenersEnabled(bool enabled, bool captureInput)
{
   mListenersEnabled = enabled;

   wxCommandEvent event(wxEVT_ENABLE_LISTENERS, GetId());
   event.SetExtraLong(captureInput);
   AddPendingEvent(event);
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::_setListenersEnabled(wxCommandEvent& event)
{
   bool captureInput = event.GetExtraLong() != 0;

   wxASSERT(!HasCapture() || !captureInput);
   if (!mListenersEnabled)
   {
      // Inform the listeners
      for (InputListenerList::iterator iter = mInputListeners.begin();
         mInputListeners.end() != iter; ++iter)
         (*iter)->onInputEventLost();

      if (HasCapture())
      {
         SetCursor(wxNullCursor);
         ReleaseMouse();
      }
   }
   else if (captureInput)
   {
      SetFocus();
      if (!HasCapture())
      {
         CaptureMouse();
         SetCursor(wxCursor(wxCURSOR_BLANK));
      }
   }

   // Not needed to be processed any more.
   event.Skip(false);
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::OnSize(wxSizeEvent& evt)
{
   // FIXME: Thread-safty!
   if (mRenderWindow)
   {
      int width, height;
      GetClientSize(&width, &height);
      Ogre::Real ratio = Ogre::Real(width) / Ogre::Real(height);

      // Set the aspect ratio of each camera that is connected to this
      // render target
      for (unsigned int i = 0; i < mRenderWindow->getNumViewports(); ++i)
      {
         mRenderWindow->getViewport(i)->getCamera()->setAspectRatio(ratio);
      }

      // Let Ogre know the window has been resized.
      mRenderWindow->windowMovedOrResized();
   }

   if (mListenersEnabled)
   {
      // Fire the registered size event callbacks
      _enterMainThreadMutex();
      for (InputListenerList::iterator iter = mInputListeners.begin();
         mInputListeners.end() != iter; ++iter)
      {
         (*iter)->onWindowSize(evt);
      }
      _leaveMainThreadMutex();
   }

   // Repaint the window during the next event loop iteration.
   // use Update instead?
   Refresh();

   evt.Skip();
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::OnMouseEvent(wxMouseEvent& evt)
{
   if (mListenersEnabled)
   {
      for (InputListenerList::iterator iter = mInputListeners.begin();
         mInputListeners.end() != iter; ++iter)
         (*iter)->onMouseEvent(evt);
   }
   else
   {
      evt.Skip();
   }
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::OnMouseCapureLost(wxMouseCaptureLostEvent& evt)
{
   SetCursor(wxNullCursor);

   if (mListenersEnabled)
   {
      for (InputListenerList::iterator iter = mInputListeners.begin();
         mInputListeners.end() != iter; ++iter)
         (*iter)->onInputEventLost();
   }
   mListenersEnabled = false;   // NOTE

   // Event is not skipped to inform the framework that it is processed.
   evt.Skip(false);
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::OnCharEvent(wxKeyEvent& evt)
{
   if (mListenersEnabled)
   {
      for (InputListenerList::iterator iter = mInputListeners.begin();
         mInputListeners.end() != iter; ++iter)
         (*iter)->onCharEvent(evt);
   }
   else
   {
      evt.Skip();
   }
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::OnKeyDownEvent(wxKeyEvent& evt)
{
   if (mListenersEnabled)
   {
      for (InputListenerList::iterator iter = mInputListeners.begin();
         mInputListeners.end() != iter; ++iter)
         (*iter)->onKeyDownEvent(evt);
   }
   else
   {
      evt.Skip();
   }
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::OnKeyUpEvent(wxKeyEvent& evt)
{
   if (mListenersEnabled)
   {
      for (InputListenerList::iterator iter = mInputListeners.begin();
         mInputListeners.end() != iter; ++iter)
         (*iter)->onKeyUpEvent(evt);
   }
   else
   {
      evt.Skip();
   }
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::OnRenderTimer(wxTimerEvent& evt)
{
   // Make sure that Ogre's root and render window(s) were created already.
   if (mRenderWindow)
   {
      static int lastFrameTime = 0;
      // If the operations that are performed in timer events are longer
      // than timer's period, the top-level windows of the wxWidgets (like
      // main frame) will not be closed (bug?). To prevent this, the period
      // is adjusted to the time that rendering takes, plus an extra time as
      // tolerance. Note that with "5ms" tolerance, CPU usage does not
      // exceed 90%.
      if (mRenderTimer->GetInterval() < lastFrameTime)
         mRenderTimer->Start(lastFrameTime + 5);
      else if (mRenderTimer->GetInterval() - 5 > mRenderTimerPeriod)
         mRenderTimer->Start(lastFrameTime > mRenderTimerPeriod ?
                        lastFrameTime + 5 : mRenderTimerPeriod);

      wxStopWatch sw;

      // FIXME: Thread-safty!
      if (mCallRenderFrameOnTimer)
         Ogre::Root::getSingleton().renderOneFrame();
      else
         Update();

      lastFrameTime = sw.Time();

      if (mListenersEnabled){
	for (InputListenerList::iterator iter = mInputListeners.begin();
               mInputListeners.end() != iter; ++iter)
              (*iter)->onRenderTimer (evt);
      }

   }
}
//----------------------------------------------------------------------------
void wxOgreRenderWindow::OnPaint(wxPaintEvent& evt)
{
   // An instance of wxPaintDC must be created always in OnPaint event
   // (even if it's not used).
   wxPaintDC dc(this);

   // FIXME: Thread-safty!
   Update();
}
//----------------------------------------------------------------------------
const Ogre::String wxOgreRenderWindow::_getOgreHandle() const
{
#if defined(__WXMSW__)
   // Handle for Windows systems
   return Ogre::StringConverter::toString((size_t)((HWND)GetHandle()));
#elif defined(__WXGTK__)

  Ogre::String handle; 
  // Handle for GTK-based systems

  GtkWidget *widget = m_wxwindow;
  gtk_widget_set_double_buffered (widget, FALSE);
  gtk_widget_realize( widget );

  // Grab the window object
  GdkWindow *gdkWin = GTK_PIZZA (widget)->bin_window;
  Display* display = GDK_WINDOW_XDISPLAY(gdkWin);
  Window wid = GDK_WINDOW_XWINDOW(gdkWin);

  std::stringstream str;

  // Display
  str << (unsigned long)display << ':';

  // Screen (returns "display.screen")
  std::string screenStr = DisplayString(display);
  std::string::size_type dotPos = screenStr.find(".");
  screenStr = screenStr.substr(dotPos+1, screenStr.size());
  str << screenStr << ':';

  // XID
  str << wid << ':';

  // Retrieve XVisualInfo
  int attrlist[] = { GLX_RGBA, GLX_DOUBLEBUFFER, GLX_DEPTH_SIZE, 16,
GLX_STENCIL_SIZE, 8, None };
  XVisualInfo* vi = glXChooseVisual(display, DefaultScreen(display), attrlist);
  str << (unsigned long)vi;

  handle = str.str(); 
  return handle;

/*
  Ogre::String handle; 

  GtkWidget *widget = m_wxwindow;
  gtk_widget_set_double_buffered (widget, FALSE);
  gtk_widget_realize( widget );

  // Grab the window object
  GdkWindow *gdkWin = GTK_PIZZA (widget)->bin_window;
  Display* display = GDK_WINDOW_XDISPLAY(gdkWin);
  Window wid = GDK_WINDOW_XWINDOW(gdkWin);

  std::stringstream str;

  // Display
  str << (unsigned long)display << ':';

  // Screen (returns "display.screen")
  std::string screenStr = DisplayString(display);
  std::string::size_type dotPos = screenStr.find(".");
  screenStr = screenStr.substr(dotPos+1, screenStr.size());
  str << screenStr << ':';

  // XID
  str << wid << ':';

  // Retrieve XVisualInfo
  int attrlist[] = { GLX_RGBA, GLX_DOUBLEBUFFER, GLX_DEPTH_SIZE, 16,
GLX_STENCIL_SIZE, 8, None };
  XVisualInfo* vi = glXChooseVisual(display, DefaultScreen(display), attrlist);
  str << (unsigned long)vi;

  handle = str.str(); 
  return handle;
*/



/*
   // Handle for GTK-based systems

	std::cout << __FUNCTION__ << " aki " << std::endl;

   // wxWidgets uses several internal GtkWidgets, the GetHandle method
   // returns a different one than this, but wxWidgets's GLCanvas uses this
   // one to interact with GLX, so we do the same.
   // NOTE: this method relies on implementation details in wxGTK and could
   //      change without any notification from the developers.
   GtkWidget* privHandle = m_wxwindow;

   // prevents flickering
   gtk_widget_set_double_buffered(privHandle, false);

	std::cout << "aaaaaaaaaaaaaaaaaaa " << privHandle << std::endl;

//   GtkWidget *widget;
//   gtk_widget_realize(widget);
//	std::cout << "aaa1 " << widget << std::endl;

   // grab the window object
   GdkWindow* gdkWin = GTK_PIZZA(privHandle)->bin_window;

	std::cout << "aaa " << gdkWin << std::endl;

   Display* display = GDK_WINDOW_XDISPLAY(gdkWin);
   Window wid = GDK_WINDOW_XWINDOW(gdkWin);

	std::cout << "bbbbbbbbbbbbbbbbbbb" << std::endl;

   // screen (returns "display.screen")
   std::string screenStr = DisplayString(display);
   screenStr = screenStr.substr(screenStr.find(".") + 1, screenStr.size());

	std::cout << "ccccccccccccccccccc" << std::endl;

   std::stringstream handleStream;
   handleStream << (unsigned long)display << ':' << screenStr << ':' << wid;

   return Ogre::String(handleStream.str());
*/

#else
   #error Not supported on this platform!
#endif
}
//----------------------------------------------------------------------------


//============================================================================
// XML resource handler for wxOgreRenderWindow
//
//============================================================================

#if wxUSE_XRC

IMPLEMENT_DYNAMIC_CLASS( wxOgreRenderWindowXmlHandler, wxXmlResourceHandler )

//----------------------------------------------------------------------------

wxOgreRenderWindowXmlHandler::wxOgreRenderWindowXmlHandler()
: wxXmlResourceHandler()
{
   AddWindowStyles();
}
//----------------------------------------------------------------------------
wxObject *wxOgreRenderWindowXmlHandler::DoCreateResource()
{
   XRC_MAKE_INSTANCE( control, wxOgreRenderWindow )

   control->Create(m_parentAsWindow, GetID(), GetPosition(), GetSize(), GetStyle() );
   // Get parameters
   if (HasParam(wxT("RenderPeriod")))
      control->setRenderTimerPeriod(GetLong(wxT("RenderPeriod")));
   if (HasParam(wxT("CallRenderFrameOnTimer")))
      control->callRenderFrameOnTimer(GetBool(wxT("CallRenderFrameOnTimer")));

   SetupWindow(control);

   return control;
}
//----------------------------------------------------------------------------
bool wxOgreRenderWindowXmlHandler::CanHandle(wxXmlNode* node)
{
   return IsOfClass(node, wxT("wxOgreRenderWindow"));
}
//----------------------------------------------------------------------------

#endif   // wxUSE_XRC 
