include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = Triva

Triva_OBJC_FILES = \
	TrivaFilter.m \
	TrivaComposition.m \
	TrivaSeparation.m \
	TrivaSquare.m \
	TrivaSquareFixed.m \
	TrivaRhombus.m \
	TrivaMarker.m \
	BasicTree.m \
	TrivaTree.m \
	TrivaTreemap.m \
	TrivaGraph.m \
	TrivaGraph+Layout.m \
	TrivaWindow.m \
	TrivaConfiguration.m

Triva_HEADER_FILES = TrivaFilter.h \
	TrivaComposition.h \
	TrivaSeparation.h \
	TrivaSquare.h \
	TrivaSquareFixed.h \
	TrivaRhombus.h \
	TrivaMarker.h \
	BasicTree.h \
	TrivaTree.h \
	TrivaTreemap.h \
	TrivaGraph.h \
	NSPointFunctions.h \
	TrivaWindow.h \
	TrivaConfiguration.h

Triva_INCLUDE_DIRS += 
Triva_LDFLAGS +=  -lm -lgraph -lgvc -lmatheval

include $(GNUSTEP_MAKEFILES)/framework.make
