#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

static NSDictionary *pos;
static int count;

void DrawManager::createHierarchy ()
{
	id instance = [viewController rootInstance];

	[position newHierarchyOrganization: this->internalCreateContainersDictionary(instance)];
	pos =  [position positionForAllNodes];
	this->internalDrawContainers (instance, currentVisuNode);
	NSLog (@"positionDict = %@", pos);
}

LayoutContainer *DrawManager::internalDrawContainers (id entity, Ogre::SceneNode *node)
{
	Ogre::SceneNode *n = node->createChildSceneNode();
	Ogre::Entity *e = mSceneMgr->createEntity ([[entity name] cString], 
					Ogre::SceneManager::PT_CUBE);
	e->setMaterialName ("VisuApp/Base");
	Ogre::SceneNode *entn = n->createChildSceneNode([[entity name] cString]);
	entn->attachObject (e);
	entn->setScale (.3,.01,.3);
	entn->setInheritScale (false);
	NSLog (@"[entity name] = %@", [entity name]);

	Ogre::Vector3 newPos;
	NSArray *nodePos = [pos objectForKey: [entity name]];
	if ([nodePos count] == 2){
		newPos =  Ogre::Vector3 (Ogre::Real([[nodePos objectAtIndex: 0]
doubleValue]*2), 0, Ogre::Real([[nodePos objectAtIndex: 1] doubleValue]*2));	
	}else{
		newPos =  Ogre::Vector3 (0,0,0);
	}
	n->setPosition (newPos);

	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:entity]] objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [viewController enumeratorOfContainersTyped:et inContainer:entity];
			while ((sub = [en2 nextObject]) != nil) {
				this->internalDrawContainers ((id)sub, n);
			}
		}
/*
		}else if ([et isKindOfClass: [PajeStateType class]]){
			NSEnumerator *en3;
			PajeEntity *ent;
		
			en3 = [viewController enumeratorOfEntitiesTyped:et
					inContainer:entity
					fromTime:[viewController startTime]
					toTime:[viewController endTime]
					minDuration: 0];
			while ((ent = [en3 nextObject]) != nil) {
				Ogre::SceneNode *ssn;
				ssn = n->createChildSceneNode();
				NSString *ide = [NSString stringWithFormat: @"%@-%d", [ent name], count++];
				Ogre::Entity *ste = mSceneMgr->createEntity ([ide cString], Ogre::SceneManager::PT_CUBE);
				NSLog (@"%@", [ent name]);
				ste->setMaterialName ([[ent name] cString]);
				ssn->attachObject (ste);
				double start;
				double end;

				start = [[[ent time] description] doubleValue];
				end = [[[ent endTime] description] doubleValue];

				ssn->setPosition (0,(end-start)/2+start,0);
				ssn->setScale (0.3,(end-start)/100,0.3);
				
//				NSLog (@"State name=%@ starttime=%f endtime=%f", [ent name], [[[ent time] description] doubleValue], [[[ent endTime] description] doubleValue]);
//				[st redraw];
//				[ret addState:st];
			}
		}
*/
	}
	LayoutContainer *ret = nil;
	return ret;
}

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

