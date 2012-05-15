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
LDFLAGS=-L../Triva/Triva.framework/Versions/Current/ 
ADDITIONAL_TOOL_LIBS = -lTriva -lPajeGeneral -lm -lgraph -lgvc -lmatheval -lRenaissance

include $(GNUSTEP_MAKEFILES)/application.make
