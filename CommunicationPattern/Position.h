#ifndef __POSITION_H
#define __POSITION_H
#include <Foundation/Foundation.h>

@interface Position : NSObject
{
}
+ (id) positionWithAlgorithm: (NSString *) type;
- (void) addLinkBetweenNode: (NSString *) nodeName andNode: (NSString *) nodeName2;
- (void) addNode: (NSString *) nodeName;
- (void) delNode: (NSString *) nodeName;
- (int) positionXForNode: (NSString *) nodeName;
- (int) positionYForNode: (NSString *) nodeName;
- (void) setPositionX: (int) x forNode: (NSString *) nodeName;
- (void) setPositionY: (int) y forNode: (NSString *) nodeName;
- (NSMutableDictionary *) positionForAllNodes;
- (NSSet *) allLinks;
- (void) newHierarchyOrganization: (NSDictionary *) hierarchy;
@end

#include "PositionGraphviz.h"

#endif
