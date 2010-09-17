AC_INIT(Triva,[1.2],schnorr@gmail.com,Triva)

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
AC_CHECK_HEADERS([regex.h], , AC_ERROR([regex.h required]))
AC_CHECK_FUNC([regcomp])
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

#components that are always compiled
CONFIG_FILES="
  App/GNUmakefile \
  Triva/GNUmakefile \
  GraphConfiguration/GNUmakefile \
  GraphView/GNUmakefile \
  LinkView/GNUmakefile \
  Dot/GNUmakefile \
  CheckTrace/GNUmakefile \
  StatTrace/GNUmakefile \
  List/GNUmakefile \
  Instances/GNUmakefile \
  LinkView/GNUmakefile \
  SquarifiedTreemap/GNUmakefile \
  TimeInterval/GNUmakefile \
  TimeSliceAggregation/GNUmakefile \
  TypeFilter/GNUmakefile \
  TimeSync/GNUmakefile \
  contrib/GNUmakefile \
  contrib/SimGridColors/GNUmakefile \
  Difference/GNUmakefile \
  GNUmakefile"

AC_CONFIG_FILES($CONFIG_FILES)
AC_OUTPUT
