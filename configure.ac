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

AC_CANONICAL_SYSTEM
ARCHITECTURE=$host_cpu
AC_SUBST(ARCHITECTURE)

AM_INIT_AUTOMAKE([gnu -Wno-portability])

dnl ---------------------------------------------------------------------------
dnl
dnl check for matheval
function check_for_matheval ()
{
	AC_CHECK_HEADER([matheval.h],
		AC_CHECK_FUNC([evaluator_create],[have_matheval="yes"],[have_matheval="no"]),[have_matheval="no"])
	AC_CHECK_LIB([matheval],[evaluator_create])
}

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
dnl defining name of the binary (Triva is default)
if test -z $PROJECT_NAME; then
	PROJECT_NAME=Triva
fi
AC_SUBST(PROJECT_NAME)
AC_DEFINE_UNQUOTED([PROJECT_NAME], "${PROJECT_NAME}",
	[Define name of the project])


#components that are always compiled
CONFIG_FILES="GNUmakefile TimeInterval/GNUmakefile Triva/GNUmakefile"
PROJECTS="Triva TimeInterval"

#flag to control if at least one (and only one) of components is activated
FLAG=no

##########################
### LinkView           ###
##########################
AC_ARG_ENABLE(LinkView,
  [  --enable-LinkView],
  [enableLinkView=yes])
if test x$enableLinkView = xyes ; then
	check_for_graphviz
	CONFIG_FILES="$CONFIG_FILES TimeSliceAggregation/GNUmakefile LinkView/GNUmakefile"
	PROJECTS="$PROJECTS TimeSliceAggregation LinkView"
	AC_DEFINE([HAVE_LINKVIEW], [1], [Enable LinkView])
	FLAG=yes
fi

##########################
### GraphConfiguration ###
##########################
AC_ARG_ENABLE(GraphConfiguration,
  [  --enable-GraphConfiguration],
  [enableGraphConfiguration=yes])
if test x$enableGraphConfiguration = xyes ; then
	check_for_matheval
	check_for_graphviz
	CONFIG_FILES="$CONFIG_FILES TimeSliceAggregation/GNUmakefile GraphConfiguration/GNUmakefile GraphView/GNUmakefile"
	PROJECTS="$PROJECTS TimeSliceAggregation GraphConfiguration GraphView"
	AC_DEFINE([HAVE_GRAPHCONFIGURATION], [1], [Enable GraphConfiguration])
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

CPPFLAGS="-I../../ -I../ -I../Triva -I./ $CPPFLAGS"
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
