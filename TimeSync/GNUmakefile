include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = TimeSync

TimeSync_PRINCIPAL_CLASS = TimeSync
TimeSync_INSTALL_DIR = $(GNUSTEP_BUNDLES)/Triva
TimeSync_RESOURCE_FILES = TimeSync.gsmarkup
TimeSync_OBJC_FILES = \
		TimeSync.m \
		CompareView.m \
		TimeSyncController.m \
		TimeSyncController+TypeHierarchy.m \
		TimeSyncController+Marker.m
TimeSync_GUI_LIBS = -lRenaissance

include $(GNUSTEP_MAKEFILES)/bundle.make
