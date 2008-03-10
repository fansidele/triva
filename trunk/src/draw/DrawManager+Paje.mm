#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

NSDictionary *pos;

LayoutContainer *DrawManager::internalDrawContainers (id entity, Ogre::SceneNode *node)
{
	LayoutContainer *ret = [[LayoutContainer alloc] init];
	[ret createWithIdentifier: [entity name] andMaterial: nil];

	Ogre::Vector3 newPos;
	NSArray *nodePos = [pos objectForKey: [entity name]];
	if ([nodePos count] == 2){
		newPos =  Ogre::Vector3 (Ogre::Real([[nodePos objectAtIndex: 0]
doubleValue]), 0, Ogre::Real([[nodePos objectAtIndex: 1] doubleValue]));	
	}else{
		newPos =  Ogre::Vector3 (0,0,0);
	}

	Ogre::SceneNode *newnode = [ret attachTo: node];
	[ret setPosition: newPos];

	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:entity]] objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [viewController enumeratorOfContainersTyped:et inContainer:entity];
			while ((sub = [en2 nextObject]) != nil) {
				LayoutContainer *lc = this->internalDrawContainers((id)sub,newnode);	
				[ret addSubContainer: lc];
			}
		}else{
			/* others */
			NSEnumerator *en3;
			PajeEntity *ent;
			
			en3 = [viewController enumeratorOfEntitiesTyped:et
					inContainer:entity
					fromTime:[viewController startTime]
					toTime:[viewController endTime]
					minDuration: 0];
			while ((ent = [en3 nextObject]) != nil) {
				NSLog(@"e%@", [ent name]);
			}


		}
	}
	return ret;
}

/* code to create states 
		{
			NSLog (@"oi");
			LayoutState *st = [[LayoutState alloc] init];
			[st createWithIdentifier: [[viewController descriptionForEntityType: et] description] andMaterial: nil];
			[st attachTo: newnode];
			[st redraw];
			[ret addState: st];
		}
*/

NSMutableDictionary *DrawManager::internalCreateContainersDictionary (id entity)
{
	NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *me = [[NSMutableDictionary alloc] init];

	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:entity]] objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [viewController enumeratorOfContainersTyped:et inContainer:entity];
			while ((sub = [en2 nextObject]) != nil) {
				NSMutableDictionary *d = this->internalCreateContainersDictionary((id)sub);
				[me addEntriesFromDictionary: d];
			}
		}
	}
	[ret setObject: me forKey: [entity name]];
	[me release];
	[ret autorelease];
	return ret;
}

void DrawManager::drawContainers()
{
	id instance = [viewController rootInstance];

	[position newHierarchyOrganization: this->internalCreateContainersDictionary(instance)];
	pos =  [position positionForAllNodes];
	NSLog (@"positionDict = %@", pos);

	rootLayout = this->internalDrawContainers (instance, mSceneMgr->getRootSceneNode());

/*
	NSEnumerator *en;
	PajeEntityType *et;
	id instance = [viewController rootInstance];
	en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:instance]] objectEnumerator];
	NSLog (@"is %@", [viewController descriptionForEntityType: instance]);

	while ((et = [en nextObject]) != nil) {
		NSLog (@"et = %@", et);
		if ([viewController isContainerEntityType:et]) {
		}
	}
*/
}
/*
void DrawManager::updateContainersPositions ()
{
	XContainer *root = [viewController root];
	if (root == NULL){
		return;
	}

	[position newHierarchyOrganization: [viewController hierarchyOrganization]];


	NSDictionary *newLinks = [viewController newLinksBetweenContainers];
	if (newLinks != nil){
		NSArray *allKeys = [newLinks allKeys];
		unsigned int i;
		for (i = 0; i < [allKeys count]; i++){
			NSString *sourceName = [allKeys objectAtIndex: i];
			NSString *destName = [newLinks objectForKey: sourceName];
			[position addLinkBetweenNode: sourceName andNode:
destName];
		}
	}

	NSArray *allContainers = [root allLeafContainers];
	NSMutableDictionary *positions = [position positionForAllNodes];
	unsigned int i;
	for (i = 0; i < [allContainers count]; i++){
		XContainer *cont = [allContainers objectAtIndex: i];
		NSString *ide = [cont identifier];	
		NSArray *nodePos = [positions objectForKey: ide];
		Ogre::Vector3 newPos;
		if ([nodePos count] == 2){
			newPos =  Ogre::Vector3 (Ogre::Real([[nodePos objectAtIndex: 0] doubleValue]), 0, Ogre::Real([[nodePos objectAtIndex: 1] doubleValue]));
		}else{
			newPos =  Ogre::Vector3 (0,0,0);
		}
		[cont setPosition: newPos];
	}




#ifdef OLD_METHOD_USED_WITH_GRAPHVIZ
	NSSet *containersDefined = [NSSet setWithArray: [[position positionForAllNodes] allKeys]];
	NSArray *allContainers = [root allContainers];

	unsigned int i;
	for (i = 0; i < [allContainers count]; i++){
		NSString *contID = (NSString *)[[allContainers objectAtIndex: i] identifier];
		if ([containersDefined member: contID] == nil){
			[position addNode: contID];
		}
	}



	NSMutableDictionary *positions = [position positionForAllNodes];
	for (i = 0; i < [allContainers count]; i++){
		XContainer *cont = [allContainers objectAtIndex: i];
		NSString *ide = [cont identifier];	
		NSArray *nodePos = [positions objectForKey: ide];
		Ogre::Vector3 newPos;
		if ([nodePos count] == 2){
			newPos =  Ogre::Vector3 (Ogre::Real([[nodePos objectAtIndex: 0] doubleValue]), 0, Ogre::Real([[nodePos objectAtIndex: 1] doubleValue]));
		}else{
			newPos =  Ogre::Vector3 (0,0,0);
		}
		[cont setPosition: newPos];
	}
#endif
}

void DrawManager::updateContainerDrawings ()
{
	bool x = [viewController containersLabelsAppearance];
	int visible = (int)x;
	XContainer *root = [viewController root];
	NSMutableArray *ar = [root allContainers];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		XContainer *cont = [ar objectAtIndex: i];
		if (![cont layout]){
			LayoutContainer *lay = [[LayoutContainer alloc] init];
			[cont setLayout: lay];
			[lay setVisibility: visible];
		}
	}
}
*/
