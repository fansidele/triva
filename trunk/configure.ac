AC_INIT(triva,0.3,schnorr@gmail.com,triva)
#AC_CONFIG_HEADER(config.h)

# check for GNUstep
if test -z "$GNUSTEP_SYSTEM_ROOT"; then
        AC_MSG_ERROR([You must run the GNUstep.sh script before configuring])
fi


AC_LANG_CPLUSPLUS
AC_PROG_CXX
#AM_PROG_LIBTOOL



PKG_CHECK_MODULES(OGRE, [OGRE >= 1.4])
CPPFLAGS="$CPPFLAGS $OGRE_CFLAGS"
LIBS="$LIBS $OGRE_LIBS"

#PKG_CHECK_MODULES(OIS, OIS >= 1.0.0, [ois_found=yes],[ois_found=no])
#CPPFLAGS="$CPPFLAGS $OIS_CFLAGS"
#LIBS="$LIBS $OIS_LIBS"

#PKG_CHECK_MODULES(CEGUI, CEGUI >= 0.5.0, [cegui_found=yes],[cegui_found=no])
#CEGUI_LIBS="$CEGUI_LIBS -lCEGUIOgreRenderer"
#CPPFLAGS="$CPPFLAGS $CEGUI_CFLAGS"
#LIBS="$LIBS $CEGUI_LIBS"

#PKG_CHECK_MODULES(GVC,GVC >= 3.0, [gvc_found=yes],[gvc_found=no])
GVC_CFLAGS="-I/usr/include/graphviz"
GVC_LIBS="-L/usr/lib -lgvc"
CPPFLAGS="$CPPFLAGS $GVC_CFLAGS"
LIBS="$LIBS $GVC_LIBS"

PKG_CHECK_MODULES(GTK, gtk+-2.0)
CPPFLAGS="$CPPFLAGS $GTK_CFLAGS"
LIBS="$LIBS $GTK_LIBS"

AM_OPTIONS_WXCONFIG
reqwx=2.8.0
AM_PATH_WXCONFIG($reqwx, wxWin=1)
if test "$wxWin" != 1; then
	AC_MSG_ERROR([
		wxWidgets must be installed on your system.
 
		Please check that wx-config is in path, the directory
		where wxWidgets libraries are installed (returned by
		'wx-config --libs' or 'wx-config --static --libs' command)
		is in LD_LIBRARY_PATH or equivalent variable and
		wxWidgets version is $reqwx or above.
		])
fi
CPPFLAGS="$CPPFLAGS -DWXINTL_NO_GETTEXT_MACRO"
CPPFLAGS="$CPPFLAGS $WX_CPPFLAGS"
CXXFLAGS="$CXXFLAGS $WX_CXXFLAGS_ONLY"
CFLAGS="$CFLAGS $WX_CFLAGS_ONLY"
LIBS="$LIBS $WX_LIBS"

CPPFLAGS="-I../../ -I../ -I./ $CPPFLAGS"
LIBS="$LIBS -lGL"
AC_SUBST(CPPFLAGS)
AC_SUBST(LIBS)

AC_CONFIG_FILES(GNUmakefile 
src/GNUmakefile 
src/core/GNUmakefile
src/general/GNUmakefile
src/reader/GNUmakefile
src/paje-simulator/GNUmakefile
src/gui/GNUmakefile
src/gui/camera/GNUmakefile
src/draw/GNUmakefile
src/draw/position/GNUmakefile 
src/draw/layout/GNUmakefile
src/draw/extras/GNUmakefile
src/draw/ambient/GNUmakefile
docs/GNUmakefile)
AC_OUTPUT

AC_MSG_NOTICE([

	Congratulations.

	* Type 'make' to compile and 'make install' to install
	])
