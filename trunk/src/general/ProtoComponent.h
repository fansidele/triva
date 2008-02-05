#ifndef __PROTOCOMPONENT_H
#define __PROTOCOMPONENT_H
#include <Foundation/Foundation.h>
#include <GenericEvent/GTimestamp.h>
#include "general/Macros.h"

@class XContainer;

@interface ProtoComponent  : NSObject
{
	ProtoComponent *input;
	ProtoComponent *output;
}
- (void) setInput: (ProtoComponent *) inp;
- (void) setOutput: (ProtoComponent *) outp;
- (void) input: (id) object;
- (void) output: (id) object;
@end

@interface ProtoComponent (Queries)
/* Queries: messages from (visualization) to (data sources) */
- (NSString *) startTime;
- (NSString *) endTime;
- (BOOL) hasMoreData;
//- (ProtoObject *) nextObject;
- (XContainer *) root;
- (id) hierarchy; // to the simulator obtain the hierarchy of reader (dimvisual)
- (NSDictionary *) newLinksBetweenContainers;
- (NSDictionary *) hierarchyOrganization; /* for graphviz with subgraph supp */
@end

@interface ProtoComponent (Commands)
/* Commands: messages from (visualization) to (data sources) */
- (void) read; //for ProtoReader
@end

@interface ProtoComponent (Notifications)
/* Notifications: messages from (data sources) to (visualization) */
- (void) timeLimitsChanged;
- (void) hierarchyChanged;
- (void) connectionsChanged;
- (void) endOfData; //from ProtoReader to simulator
@end

#include "reader/ProtoReader.h"
#include "memory/ProtoMemory.h"
//#include "ogre-simulator/OgreProtoSimulator.h"

#endif
