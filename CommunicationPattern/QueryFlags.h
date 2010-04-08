#ifndef __TRIVA_QUERY_FLAGS
#define __TRIVA_QUERY_FLAGS

enum QueryFlags {
       CONTAINER_MASK = 1<<0,
       STATE_MASK = 1<<1,
       LINK_MASK = 1<<2,
       CAMERA_MASK = 1<<3,
       AMBIENT_MASK = 1<<4,
       RESOURCE_GRAPH_MASK = 1<<5
};

#endif
