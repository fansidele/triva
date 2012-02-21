include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Triva
VERSION = 1.4

AGGREGATE_NAME = Triva
SUBPROJECTS = Triva \
  App \
  GraphConfiguration \
  GraphView \
  FDGraphView \
  Dot \
  CheckTrace \
  StatTrace \
  List \
  Instances \
  SquarifiedTreemap \
  TimeInterval \
  TimeIntegration \
  SpatialIntegration \
  TypeFilter \
  TimeSync \
  contrib

include $(GNUSTEP_MAKEFILES)/aggregate.make

deb:
	sudo checkinstall --pkgname Triva -d 2 -si \
		-t debian \
		--arch x86_64 \
		--maintainer "Lucas.Schnorr@imag.fr" \
		--pkglicense "LGPL" \
		--pkgversion "1.4-rc1" \
		--requires "libgnustep-gui0.16,libgnustep-base1.19,\
			gnustep-back0.16,libmatheval1,libgraphviz4,paje" \
		./checkinstall-make
