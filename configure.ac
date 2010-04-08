AC_INIT(Triva,2.0,schnorr@gmail.com,Triva)

if test -z "$GNUSTEP_SYSTEM_ROOT"; then
        AC_MSG_ERROR([You must run the GNUstep.sh script before configuring])
fi

AC_LANG_CPLUSPLUS
AC_PROG_CXX
AC_HEADER_STDBOOL
AC_PREREQ
AC_PROG_CC
AC_CHECK_FUNCS([bzero])
AC_CHECK_HEADERS([float.h limits.h sys/time.h])
AC_PATH_PROG(PKG_CONFIG, pkg-config)

dnl ---------------------------------------------------------------------------
dnl
dnl check for libgraphviz presence
function check_for_graphviz ()
{
	AC_CHECK_HEADER([graphviz/gvc.h],
		[AC_CHECK_FUNC([gvLayout],[have_gvLayout="yes"],[have_gvLayout="no"])],  
		[have_gvLayout="no"])
	AC_CHECK_LIB([gvc],[gvLayout])
}

dnl ---------------------------------------------------------------------------
dnl
dnl check for libogre presence
function check_for_ogre ()
{
	PKG_CHECK_MODULES(OGRE, [OGRE >= 1.4])
	CPPFLAGS="$CPPFLAGS $OGRE_CFLAGS"
	LIBS="$LIBS $OGRE_LIBS"
}

dnl ---------------------------------------------------------------------------
dnl
dnl check for GTK
function check_for_gtk ()
{
	PKG_CHECK_MODULES(GTK, gtk+-2.0)
	CPPFLAGS="$CPPFLAGS $GTK_CFLAGS"
	LIBS="$LIBS $GTK_LIBS"
}

dnl ---------------------------------------------------------------------------
dnl
dnl check for WX
function check_for_wx ()
{
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
}

#components that are always compiled
CONFIG_FILES="GNUmakefile Triva/GNUmakefile TimeInterval/GNUmakefile TypeFilter/GNUmakefile"
PROJECTS="Triva TimeInterval TypeFilter"

#flag to control if at least one (and only one) of components is activated
FLAG=no

#######################
### NetworkTopology ###
#######################
AC_ARG_ENABLE(NetworkTopology,
  [  --enable-NetworkTopology],
  [enableNetworkTopology=yes])
if test x$enableNetworkTopology = xyes ; then
	check_for_ogre
	check_for_graphviz
	CONFIG_FILES="$CONFIG_FILES NetworkTopology/GNUmakefile"
	PROJECTS="$PROJECTS NetworkTopology"
	AC_DEFINE([HAVE_NETWORKTOPOLOGY], [1], [Define if NetworkTopology visualization components is activated])
	FLAG=yes
fi

############################
### CommunicationPattern ###
############################
AC_ARG_ENABLE(CommunicationPattern,
  [  --enable-CommunicationPattern],
  [enableCommunicationPattern=yes])
if test x$enableCommunicationPattern = xyes ; then
	check_for_ogre
	check_for_graphviz
	CPPFLAGS="$CPPFLAGS $OGRE_CFLAGS"
	LIBS="$LIBS $OGRE_LIBS"
	CONFIG_FILES="$CONFIG_FILES CommunicationPattern/GNUmakefile"
	PROJECTS="$PROJECTS CommunicationPattern"
	AC_DEFINE([HAVE_COMMUNICATIONPATTERN], [1], [Define if CommunicationPattern visualization components is activated])
	FLAG=yes
fi

###############
### SimGrid ###
###############
AC_ARG_ENABLE(SimGrid,
  [  --enable-SimGrid],
  [enableSimGrid=yes])
if test x$enableSimGrid = xyes ; then
	check_for_graphviz
	CONFIG_FILES="$CONFIG_FILES SimGrid/GNUmakefile"
	PROJECTS="$PROJECTS SimGrid"
	AC_DEFINE([HAVE_SIMGRID], [1], [Define if SimGrid visualization components is activated])
	FLAG=yes
fi

#########################
### SquarifiedTreemap ###
#########################
AC_ARG_ENABLE(SquarifiedTreemap,
  [  --enable-SquarifiedTreemap],
  [enableSquarifiedTreemap=yes])
if test x$enableSquarifiedTreemap = xyes ; then
	CONFIG_FILES="$CONFIG_FILES SquarifiedTreemap/GNUmakefile TimeSliceAggregation/GNUmakefile"
	PROJECTS="$PROJECTS SquarifiedTreemap TimeSliceAggregation"
	AC_DEFINE([HAVE_SQUARIFIEDTREEMAP], [1], [Define if SquarifiedTreemap visualization components is activated])
	FLAG=yes
fi

################
### NUCAView ###
################
AC_ARG_ENABLE(NUCAView,
  [  --enable-NUCAView],
  [enableNUCAView=yes])
if test x$enableNUCAView = xyes ; then
	check_for_graphviz
	CONFIG_FILES="$CONFIG_FILES NUCAView/GNUmakefile"
	PROJECTS="$PROJECTS NUCAView"
	AC_DEFINE([HAVE_NUCAVIEW], [1], [Define if NUCAView visualization components is activated])
	FLAG=yes
fi

###################################
### HCMReader + SquarifiedTreemap #
###################################
AC_ARG_ENABLE(HCMReader,
  [  --enable-HCMReader],
  [enableHCMReader=yes])
if test x$enableHCMReader = xyes ; then
	CONFIG_FILES="$CONFIG_FILES HCMReader/GNUmakefile TimeSliceAggregation/GNUmakefile SquarifiedTreemap/GNUmakefile"
	PROJECTS="$PROJECTS HCMReader TimeSliceAggregation SquarifiedTreemap"
	AC_DEFINE([HAVE_HCMREADER], [1], [Define if HCMReader visualization components is activated])
	FLAG=yes
fi

################
###   Dot    ###
################
AC_ARG_ENABLE(Dot,
  [  --enable-Dot],
  [enableDot=yes])
if test x$enableDot = xyes ; then
	check_for_graphviz
	CONFIG_FILES="$CONFIG_FILES Dot/GNUmakefile"
	PROJECTS="$PROJECTS Dot"
	AC_DEFINE([HAVE_DOT], [1], [Define if Dot output is activated])
	FLAG=yes
fi

check_for_gtk
check_for_wx

CPPFLAGS="-I../../ -I../ -I./ $CPPFLAGS"
AC_SUBST(CPPFLAGS)
AC_SUBST(LIBS)
AC_SUBST(CONFIG_FILES)
AC_SUBST(PROJECTS)

#test if at least one (and only one) of the components is enabled
if test x$FLAG != xyes ; then
	echo "You have to enable at least one of the visualization components."
	exit
fi

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES($CONFIG_FILES)
AC_OUTPUT
