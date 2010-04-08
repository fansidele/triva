#include "Position.h"

@implementation Position
+ (id) positionWithAlgorithm: (NSString *) type
{
	if ([type isEqual: @"graphviz"]){
		return [[PositionGraphviz alloc] init];
	}else{
		return nil;
	}
}
- (void) addNode: (NSString *) nodeName {}
- (void) delNode: (NSString *) nodeName {}
- (void) addLinkBetweenNode: (NSString *) nodeName andNode: (NSString *) nodeName2 {}
- (int) positionXForNode: (NSString *) nodeName { return 0;}
- (int) positionYForNode: (NSString *) nodeName { return 0;}
- (void) setPositionX: (int) x forNode: (NSString *) nodeName {}
- (void) setPositionY: (int) y forNode: (NSString *) nodeName {}
- (NSMutableDictionary *) positionForAllNodes { return nil; }
- (NSSet *) allLinks { return nil; }
- (void) newHierarchyOrganization: (NSDictionary *) hierarchy {}
@end
