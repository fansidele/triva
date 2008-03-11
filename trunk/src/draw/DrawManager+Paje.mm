#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

void DrawManager::resetCurrentVisualization ()
{
	if (currentVisuNode){
		mSceneMgr->getRootSceneNode()->removeAndDestroyAllChildren();
		currentVisuNode = NULL;
	}
	currentVisuNode = mSceneMgr->getRootSceneNode()->createChildSceneNode();
}


void DrawManager::drawContainers()
{

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
