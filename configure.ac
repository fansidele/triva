AC_INIT(Triva,2.0,schnorr@gmail.com,Triva)

if test -z "$GNUSTEP_SYSTEM_ROOT"; then
        AC_MSG_ERROR([You must run the GNUstep.sh script before configuring])
fi

AC_LANG_CPLUSPLUS
AC_PROG_CXX

PKG_CHECK_MODULES(OGRE, [OGRE >= 1.4])
CPPFLAGS="$CPPFLAGS $OGRE_CFLAGS"
LIBS="$LIBS $OGRE_LIBS"

PKG_CHECK_MODULES(GTK, gtk+-2.0)
CPPFLAGS="$CPPFLAGS $GTK_CFLAGS"
LIBS="$LIBS $GTK_LIBS"

GVC_CFLAGS="-I/usr/include/graphviz"
GVC_LIBS="-L/usr/lib -lgvc"
CPPFLAGS="$CPPFLAGS $GVC_CFLAGS"
LIBS="$LIBS $GVC_LIBS"

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
AC_SUBST(CPPFLAGS)
AC_SUBST(LIBS)

AC_CONFIG_FILES(GNUmakefile
TimeInterval/GNUmakefile
OgreView/GNUmakefile
MemoryAccess/GNUmakefile
TimeSliceAggregation/GNUmakefile
SquarifiedTreemap/GNUmakefile
SimGrid/GNUmakefile
CommunicationPattern/GNUmakefile
NetworkTopology/GNUmakefile)
AC_OUTPUT

