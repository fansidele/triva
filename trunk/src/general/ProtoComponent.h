#ifndef __PROTOCOMPONENT_H
#define __PROTOCOMPONENT_H
#include <Foundation/Foundation.h>
#include <GenericEvent/GTimestamp.h>
#include "general/Macros.h"

@class XContainer;
@class XObject;

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
- (XObject *) objectWithIdentifier: (NSString *) identifier;
- (NSArray *) dimvisualBundlesAvailable;
- (BOOL) isDIMVisualBundleLoaded: (NSString *) name;
- (NSDictionary *) getConfigurationOptionsFromDIMVisualBundle: (NSString *)name;
@end

@interface ProtoComponent (Commands)
/* Commands: messages from (visualization) to (data sources) */
- (void) read; //for ProtoReader
- (BOOL) loadDIMVisualBundle: (NSString *) bundleName;
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
