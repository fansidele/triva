include $(GNUSTEP_MAKEFILES)/common.make

CC=$(CXX)

PACKAGE_NAME=OgreView
BUNDLE_NAME=OgreView
BUNDLE_EXTENSION=.bundle
BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Triva
OgreView_PRINCIPAL_CLASS=OgreView
OgreView_RESOURCE_FILES= ogre.cfg resources.cfg plugins.cfg Media
OgreView_HAS_RESOURCE_BUNDLE = yes

OgreView_OBJC_FILES=Position.m PositionGraphviz.m
OgreView_OBJCC_FILES= \
	OgreView.mm \
	OgreView+ProtoView.mm \
	OgreView+ProtoViewBase.mm \
	OgreWindow.mm \
	OgreWindowAuto.mm \
	Triva3DFrame.mm \
	wxInputEventListener.mm \
	wxOgreRenderWindow.mm \
	CameraManager.mm \
	AmbientManager.mm Origin.mm YAxis.mm XAxis.mm ZAxis.mm Ground.mm \
	MovableText.mm \
	DrawManager+Animation.mm \
	DrawManager+ApplicationGraph.mm \
	DrawManager+Hierarchy.mm \
	DrawManager+Materials.mm \
	DrawManager.mm \
	DrawManager+Mouse.mm \
	DrawManager+Paje.mm \
	DrawManager+ResourcesGraph.mm \
	DrawManager+SquarifiedTreemap.mm \
	DrawManager+TimestampedObjects.mm \
	TrivaTreemap+Graphviz.mm \
	TrivaTreemap.mm \
	TrivaTreemapSquarified.mm \
	TrivaResourcesGraph.mm




OgreView_INCLUDE_DIRS += -I../../ -I../ -I./  -DOGRE_GUI_GLX -DOGRE_CONFIG_LITTLE_ENDIAN -I/usr/include/OGRE   -D_REENTRANT -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/pango-1.0 -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/directfb -I/usr/include/libpng12 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include   -I/usr/include/graphviz -DWXINTL_NO_GETTEXT_MACRO -I/usr/lib/wx/include/gtk2-unicode-release-2.8 -I/usr/include/wx-2.8 -D_FILE_OFFSET_BITS=64 -D_LARGE_FILES -D__WXGTK__
OgreView_LIB_DIRS +=  -lOgreMain   -lgtk-x11-2.0 -lgdk-x11-2.0 -latk-1.0 -lpangoft2-1.0 -lgdk_pixbuf-2.0 -lm -lpangocairo-1.0 -lgio-2.0 -lcairo -lpango-1.0 -lfreetype -lfontconfig -lgobject-2.0 -lgmodule-2.0 -lglib-2.0   -L/usr/lib -lgvc -pthread -Wl,-Bsymbolic-functions  -lwx_gtk2u_richtext-2.8 -lwx_gtk2u_aui-2.8 -lwx_gtk2u_xrc-2.8 -lwx_gtk2u_qa-2.8 -lwx_gtk2u_html-2.8 -lwx_gtk2u_adv-2.8 -lwx_gtk2u_core-2.8 -lwx_baseu_xml-2.8 -lwx_baseu_net-2.8 -lwx_baseu-2.8 
OgreView_LDFLAGS += 

include $(GNUSTEP_MAKEFILES)/bundle.make

after-distclean::
after-all::
after-clean:: 
