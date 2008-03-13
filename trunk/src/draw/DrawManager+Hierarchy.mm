#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

static NSDictionary *pos;

void DrawManager::createHierarchy ()
{
	id instance = [viewController rootInstance];

	[position newHierarchyOrganization: this->createContainersDictionary(instance)];
	pos =  [position positionForAllNodes];
	this->drawContainers (instance, currentVisuNode);
}

void DrawManager::drawContainers (id entity, Ogre::SceneNode *node)
{
	std::string name = std::string([[entity name] cString]);
	name.append ("-#-#-");
	name.append ([[[entity entityType] name] cString]);

	Ogre::SceneNode *n = node->createChildSceneNode([[entity name] cString]);
	Ogre::Entity *e = mSceneMgr->createEntity ([[entity name] cString], 
					Ogre::SceneManager::PT_CUBE);
	e->setUserAny (Ogre::Any (name));
	e->setMaterialName ("VisuApp/Base");
	e->setQueryFlags(CONTAINER_MASK);
	Ogre::SceneNode *entn = n->createChildSceneNode();
	entn->attachObject (e);
	entn->setScale (.3,.01,.3);
	entn->setInheritScale (false);

	MovableText *text;
	Ogre::SceneNode *entnt = n->createChildSceneNode();
	NSString *textid = [NSString stringWithFormat: @"%@-t", [entity name]];
	text = new MovableText ([textid cString], [textid cString]);
	text->setColor (Ogre::ColourValue::Blue);
	text->setCharacterHeight (15);
	entnt->setInheritScale (false);
	entnt->attachObject (text);

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
				this->drawContainers ((id)sub, n);
			}
		}
	}
}

NSMutableDictionary *DrawManager::createContainersDictionary (id entity)
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
				NSMutableDictionary *d = this->createContainersDictionary((id)sub);
				[me addEntriesFromDictionary: d];
			}
		}
	}
	[ret setObject: me forKey: [entity name]];
	[me release];
	[ret autorelease];
	return ret;
}

