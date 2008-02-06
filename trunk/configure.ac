AC_INIT(triva,25,schnorr@gmail.com,triva)
#AC_CONFIG_HEADER(config.h)

# check for GNUstep
if test -z "$GNUSTEP_SYSTEM_ROOT"; then
        AC_MSG_ERROR([You must run the GNUstep.sh script before configuring])
fi

LIBS="-L/usr/lib/"

AC_LANG_CPLUSPLUS
AC_PROG_CXX
#AM_PROG_LIBTOOL

PKG_CHECK_MODULES(OGRE, [OGRE >= 1.4])
AC_SUBST(OGRE_CFLAGS)
AC_SUBST(OGRE_LIBS)

PKG_CHECK_MODULES(OIS, OIS >= 1.0.0, [ois_found=yes],[ois_found=no])
AC_SUBST(OIS_CFLAGS)
AC_SUBST(OIS_LIBS)

PKG_CHECK_MODULES(CEGUI, CEGUI >= 0.5.0, [cegui_found=yes],[cegui_found=no])
AC_SUBST(CEGUI_CFLAGS)
CEGUI_LIBS="$CEGUI_LIBS -lCEGUIOgreRenderer"
AC_SUBST(CEGUI_LIBS)

#PKG_CHECK_MODULES(GVC,GVC >= 3.0, [gvc_found=yes],[gvc_found=no])
GVC_CFLAGS="-I/usr/include/graphviz"
GVC_LIBS="-L/usr/lib -lgvc"
AC_SUBST(GVC_CFLAGS)
AC_SUBST(GVC_LIBS)

AC_CONFIG_FILES(GNUmakefile 
src/GNUmakefile 
src/core/GNUmakefile
src/general/GNUmakefile
src/reader/GNUmakefile
src/memory/GNUmakefile
src/ogre-simulator/GNUmakefile
src/view/GNUmakefile
src/view/exit/GNUmakefile
src/view/draw/GNUmakefile
src/view/draw/position/GNUmakefile 
src/view/draw/layout/GNUmakefile
src/view/extras/GNUmakefile
src/view/camera/GNUmakefile
src/view/ambient/GNUmakefile
src/view/keyboard/GNUmakefile
src/view/mouse/GNUmakefile
src/view/cegui/GNUmakefile)
AC_OUTPUT

AC_MSG_NOTICE([

	Congratulations.

	* Type 'make' to compile and 'make install' to install
	])
