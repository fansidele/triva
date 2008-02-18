#ifndef __XCONTAINER_H
#define __XCONTAINER_H
#include <Foundation/Foundation.h>
#include "XObject.h"

@interface XContainer : XObject
{
	NSMutableArray *subContainers;
	NSMutableArray *states;

	NSMutableDictionary *links; /* organized for key */

}
- (void) addLink: (XLink *) l withKey: (NSString *) k;
- (void) addState: (XState *) ps;
- (void) addSubContainer: (XContainer *) pt;
- (XContainer *) containerWithIdentifier: (NSString *) ide;
- (NSMutableArray *) states;
- (NSMutableArray *) allContainersIdentifiers; /* array of NSStrings */
- (NSMutableArray *) allContainers; /* array of XContainers */
- (NSMutableArray *) allLeafContainers; /* array of XContainers that are leafs*/
- (NSMutableArray *) allContainersWithStates;
- (NSMutableArray *) allFinalizedLinks;
- (NSMutableArray *) allContainersWithFinalizedLinks;
- (XState *) getLastState;
- (XLink *) linkWithKey: (NSString *) key;

//EXPERIMENTAL TO HELP GRAPHVIZ SHOW SUBGRAPHS AS CLUSTER
- (NSMutableDictionary *) containersDictionary;
@end

@interface XContainer (Search)
- (XState *) stateWithIdentifier: (NSString *) ide; //recursive
@end

#endif
