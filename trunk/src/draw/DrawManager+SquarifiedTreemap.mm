#include "DrawManager.h"

void DrawManager::drawContainersIntoTreemapBase ()
{
	id instance = [viewController rootInstance];
	this->drawContainersIntoTreemapBase (instance);
}

void DrawManager::drawOneContainerIntoTreemapbase 
		(id entity, Ogre::SceneNode *node, NSPoint loc)
{
	std::string orname = std::string ([[entity name] cString]);
	std::string name = std::string(orname);
	name.append ("-#-#-");
	name.append ([[[entity entityType] name] cString]);

	Ogre::SceneNode *n;
	try {
		n = node->createChildSceneNode (orname);

	}catch (Ogre::Exception ex){
		n = mSceneMgr->getSceneNode (orname);
		n->setPosition(loc.x, 0, loc.y);
		return;
	}
	Ogre::Entity *e;
	try {
		e = mSceneMgr->getEntity(orname);
	}catch (Ogre::Exception ex){
		e = mSceneMgr->createEntity (orname, 
				Ogre::SceneManager::PT_CUBE);
	}
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

	n->setPosition (loc.x, 0, loc.y);

/*
	Ogre::Vector3 newPos;
	NSArray *nodePos = [pos objectForKey: [entity name]];
	if ([nodePos count] == 2){
		newPos =  Ogre::Vector3 (Ogre::Real([[nodePos objectAtIndex: 0]
doubleValue]*2), 0, Ogre::Real([[nodePos objectAtIndex: 1] doubleValue]*2));	
	}else{
		newPos =  Ogre::Vector3 (0,0,0);
	}
	n->setPosition (newPos);
*/
}


void DrawManager::drawContainersIntoTreemapBase (id entity)
{
	PajeEntityType *et;
	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity: entity]] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			PajeContainer *sub;
			NSEnumerator *en2 = [viewController enumeratorOfContainersTyped:et inContainer: entity];
			while ((sub = [en2 nextObject]) != nil) {
				//do something with
//				NSLog (@"sub=%@ ==> %@", [sub name], [[viewController searchWithPartialName: [sub name]] name]);


				TrivaTreemap *treemap = [viewController 
					searchWithPartialName: [sub name]];
				if (treemap == nil){
					NSLog (@"error");
				}else{
	
					Ogre::SceneNode *node;
					node = mSceneMgr->getSceneNode 
						([[treemap name] cString]);
					NSPoint loc = [treemap nextLocation];
					this->drawOneContainerIntoTreemapbase 
						((id)sub, node, loc);
//					NSLog (@"ok %@ %p", treemap, node);
				}


				this->drawContainersIntoTreemapBase ((id)sub);
			}
		}
	}
}
