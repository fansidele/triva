include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Triva

Triva_OBJC_FILES = \
	Triva_main.m \
	TrivaApplication.m \
	TrivaApplication+Bundles.m \
	TrivaCommand.m \
	TrivaController.m \
	TrivaController+Chunks.m \
	TrivaController+Components.m \
	TrivaComparisonController.m \
	TrivaServerSocket.m

Triva_APPLICATION_ICON = Triva.tiff
Triva_RESOURCE_FILES = Triva.tiff trivaInfo.plist Triva.plist
Triva_LDFLAGS = -lTriva -lGeneral

include $(GNUSTEP_MAKEFILES)/application.make
