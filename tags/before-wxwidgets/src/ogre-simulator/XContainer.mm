#include "XContainer.h"

@implementation XContainer
- (id) init
{
	self = [super init];
	subContainers = [[NSMutableArray alloc] init];
	states = [[NSMutableArray alloc] init];

	links = [[NSMutableDictionary alloc] init];
	return self;
}

- (void) addSubContainer: (XContainer *) pt
{
	[subContainers addObject: pt];
}

- (XContainer *) containerWithIdentifier: (NSString *) ide
{
	unsigned int i;

	if ([identifier isEqual: ide]){
		return self;
	}

	for (i = 0; i < [subContainers count]; i++){
		XContainer *o = [subContainers objectAtIndex: i];
		if ([[o identifier] isEqual: ide]){
			return o;
		}
	}
	/* descending */
	for (i = 0; i < [subContainers count]; i++){
		XContainer *o = [subContainers objectAtIndex: i];
		XContainer *ret = [o containerWithIdentifier: ide];
		if (ret != nil){
			return ret;
		}
	}
	/* returning nil */
	return nil;
}

- (void) addState: (XState *) ps
{
	[states addObject: ps];
}

- (void) addLink: (XLink *) l withKey: (NSString *) k
{
	[links setObject: l forKey: k];
}

- (NSMutableArray *) states
{
	return states;
}

- (XLink *) linkWithKey: (NSString *) key
{
	return (XLink *)[links objectForKey: key];
}

- (NSMutableArray *) allContainersIdentifiers
{
	unsigned int i;
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	[ret addObject: identifier];
	for (i = 0; i < [subContainers count]; i++){
		[ret addObjectsFromArray: [[subContainers objectAtIndex: i] allContainersIdentifiers]];
	}
	[ret autorelease];
	return ret;
}

- (NSMutableArray *) allContainers
{
	unsigned int i;
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	[ret addObject: self];
	for (i = 0; i < [subContainers count]; i++){
		[ret addObjectsFromArray: [[subContainers objectAtIndex: i] allContainers]];
	}
	[ret autorelease];
	return ret;
}

- (NSMutableArray *) allLeafContainers
{
	unsigned int i;
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	if ([subContainers count] == 0){
		[ret addObject: self];
	}else{
		for (i = 0; i < [subContainers count]; i++){
			[ret addObjectsFromArray: [[subContainers objectAtIndex:
i] allLeafContainers]];
		}
	}
	[ret autorelease];
	return ret;
}

- (NSMutableArray *) allContainersWithStates
{
	return [self allLeafContainers];
}

- (NSMutableArray *) allFinalizedLinks
{
	unsigned int i;
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	NSArray *ar = [links allKeys];
	for (i = 0; i < [ar count]; i++){
		NSString *key = [ar objectAtIndex: i];
		XLink *l = [links objectForKey: key];
		if ([l finalized]){
			[ret addObject: l];
		}
	}
	[ret autorelease];
	return ret;
}

- (NSMutableArray *) allContainersWithFinalizedLinks
{
	unsigned int i;
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	[ret addObjectsFromArray: [self allFinalizedLinks]];
	for (i = 0; i < [subContainers count]; i++){
		[ret addObjectsFromArray: [[subContainers objectAtIndex: i]
allContainersWithFinalizedLinks]];
	}
	[ret autorelease];
	return ret;
}

- (void) setLayout: (Layout *) lay
{
	[super setLayout: lay];
	[layout createWithIdentifier: identifier andMaterial: type];
	[layout attachTo: node];
}

- (void) updateLayout
{
}

- (XState *) getLastState
{
	XState *ret = nil;
	if ([states count] > 0){
		ret = (XState *)[states objectAtIndex: ([states count] - 1)];
	}
	return ret;
}

- (NSMutableDictionary *) containersDictionary
{
	NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *me = [[NSMutableDictionary alloc] init];

	unsigned int i;
	for (i = 0; i < [subContainers count]; i++){
		XContainer *child = [subContainers objectAtIndex: i];
		[me addEntriesFromDictionary: [child containersDictionary]];
	}
	[ret setObject: me forKey: identifier];
	[me release];
	[ret autorelease];
	return ret;
}
@end
