#include "OgreProtoSimulator.h"

@implementation OgreProtoSimulator
- (id) init
{
	Ogre::Root *mRoot;
	Ogre::SceneManager *mSceneMgr;

	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");


	self = [super init];
	root = [[XContainer alloc] init];
	[root setIdentifier: @"root"];
	[root setNode: mSceneMgr->getRootSceneNode()];

	NSLog (@"%@: root = %@", self, root);

	currentTime = nil;
	startTime = nil;
	endTime = nil;

	hierarchy = nil; /* must be initalized after all componentes are
conected */

	links = [[NSMutableDictionary alloc] init];
	newLinks = [[NSMutableDictionary alloc] init];


	return self;
}

- (void) dealloc
{
	[links release];
	[super dealloc];
}

- (void) simulate: (id) object
{
	static int flagHierarchyChanged = NO;
	static int flagTimeLimitsChanged = NO;
	static int initHierarchy = YES;

	if (initHierarchy){
		hierarchy = [self hierarchy];
		initHierarchy = NO;
	}

	unsigned int i;
	if (object == nil){
		return;
	}
	for (i = 0; i < [object count]; i++){
		PajeEvent *e = [object objectAtIndex: i];
		if ([e isKindOfClass: [PajeCreateContainer class]]){
			PajeCreateContainer *pcc = (PajeCreateContainer *) e;
			[self pajeCreateContainer: pcc];
			flagHierarchyChanged = YES;
		}else if ([e isKindOfClass: [PajeDestroyContainer class]]){
			PajeDestroyContainer *pcc = (PajeDestroyContainer *) e;
			[self pajeDestroyContainer: pcc];
		}else if ([e isKindOfClass: [PajePushState class]]){
			PajePushState *pps = (PajePushState *) e;
			[self pajePushState: pps];
		}else if ([e isKindOfClass: [PajePopState class]]){
			PajePopState *pps = (PajePopState *) e;
			[self pajePopState: pps];
		}else if ([e isKindOfClass: [PajeSetState class]]){
			PajeSetState *pss = (PajeSetState *) e;
			[self pajeSetState: pss];
		}else if ([e isKindOfClass: [PajeStartLink class]]){
			PajeStartLink *p = (PajeStartLink *) e;
			[self pajeStartLink: p];
		}else if ([e isKindOfClass: [PajeEndLink class]]){
			PajeEndLink *p = (PajeEndLink *) e;
			[self pajeEndLink: p];
		}
		[self setCurrentTime: [e time]];
		flagTimeLimitsChanged = YES;
	}
	if (flagHierarchyChanged == YES){
		[super hierarchyChanged];
		flagHierarchyChanged = NO;
	}

	if (flagTimeLimitsChanged == YES){
		[self updateTimeAtUnfinishedObjects];
		[super timeLimitsChanged];
		flagTimeLimitsChanged = NO;
	}
}

- (void) setCurrentTime: (NSString *) time
{
	Assign(currentTime, time);
	if (startTime == nil){
		startTime = currentTime;
	}
	Assign(endTime, currentTime);
}

- (void) updateTimeAtUnfinishedObjects
{
	NSArray *ar = [root allContainersWithStates];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		XContainer *c = (XContainer *)[ar objectAtIndex: i];
		NSArray *ar2 = [c states];
		unsigned int j;
		for (j = 0; j < [ar2 count]; j++){
			XState *s = (XState *)[ar2 objectAtIndex: j];
			if (![s finalized]){
				[s setEnd: [self endTime]];
			}
		}
	}
}


- (void) endOfData
{
//	NSLog (@"%s", __FUNCTION__);
	NSArray *ar = [root allContainersWithStates];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
//		NSLog (@"%d", [[[ar objectAtIndex: i] states] count]);
		XState *s = [[ar objectAtIndex: i] getLastState];
		[s setEnd: [self endTime]];
		[s setFinalized: YES];
//		NSLog (@"%@ %@ %@", [s identifier], [s start], [s end]);
	}
	[self timeLimitsChanged];
}

- (void) input: (id) object
{
	[self simulate: object];
}

- (XContainer *) root
{
	return root;
}

- (NSString *) startTime
{
	return startTime;
}

- (NSString *) endTime
{
	return endTime;
}

- (NSDictionary *) newLinksBetweenContainers
{
	NSDictionary *ret;
	ret = [NSDictionary dictionaryWithDictionary: newLinks];
	[newLinks removeAllObjects];
	return ret;
}

- (NSDictionary *) hierarchyOrganization
{
	return [root containersDictionary];
}
@end
