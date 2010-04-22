AC_INIT(Triva,1.0,schnorr@gmail.com,Triva)

if test -z "$GNUSTEP_SYSTEM_ROOT"; then
        AC_MSG_ERROR([You must run the GNUstep.sh script before configuring])
fi

AC_LANG_CPLUSPLUS
AC_PROG_CXX
AC_HEADER_STDBOOL
AC_PREREQ
AC_PROG_CC
AC_C_INLINE
AC_FUNC_MALLOC
AC_CHECK_FUNCS([sqrt])
AC_CHECK_FUNCS([bzero])
AC_CHECK_HEADERS([float.h limits.h sys/time.h])
AC_CHECK_HEADER([argp.h], , AC_ERROR([argp.h required]))
AC_CHECK_FUNC([argp_parse])
AC_CHECK_HEADER([matheval.h], , AC_ERROR([matheval.h required]))
AC_CHECK_LIB([matheval], [evaluator_create])
AC_CHECK_HEADER([graphviz/gvc.h], , AC_ERROR([graphviz/gvc.h required]))
AC_CHECK_LIB([gvc],[gvLayout])

AC_CANONICAL_SYSTEM
ARCHITECTURE=$host_cpu
AC_SUBST(ARCHITECTURE)

AM_INIT_AUTOMAKE([gnu -Wno-portability])

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
CONFIG_FILES="
  Triva/GNUmakefile \
  GraphConfiguration/GNUmakefile \
  GraphView/GNUmakefile \
  Dot/GNUmakefile \
  CheckTrace/GNUmakefile \
  List/GNUmakefile \
  Instances/GNUmakefile \
  LinkView/GNUmakefile \
  SquarifiedTreemap/GNUmakefile \
  TimeInterval/GNUmakefile \
  TimeSliceAggregation/GNUmakefile \
  contrib/GNUmakefile \
  contrib/SimGridColors/GNUmakefile \
  GNUmakefile"

CPPFLAGS="-I../../ -I../ -I../Triva -I./ $CPPFLAGS"
AC_SUBST(CPPFLAGS)
AC_SUBST(LIBS)
AC_SUBST(CONFIG_FILES)
AC_SUBST(PROJECTS)

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES($CONFIG_FILES)
AC_OUTPUT
