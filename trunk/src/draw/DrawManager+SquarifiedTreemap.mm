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


//from DrawManager+Base.mm

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

void DrawManager::treemapRecursiveDraw (TrivaTreemap *root, Ogre::SceneNode *node)
{
//        NSLog (@"%.0f name:%@ area (%.1f x %.1f) x=%.1f y=%.1f",
//		[root depth],
//                [root name], [root width], [root height], [root x], [root y]);

	if (root == nil || node == NULL){
		return;
	}

	if ([root value] <= 0){
		//no value, just return
		return;
	}

	std::string orname = std::string ([[root name] cString]);
	Ogre::SceneNode *n1 = node->createChildSceneNode(orname);
	n1->setPosition ([root x], 0, [root y]);
	Ogre::Entity *e;
	try {
		e = mSceneMgr->getEntity ([[root name] cString]);
	}catch (Ogre::Exception ex){
		e = mSceneMgr->createEntity ([[root name] cString],
				Ogre::SceneManager::PT_CUBE);
	}
	std::string materialname = "Triva/Treemap/";
	materialname.append ([[NSString stringWithFormat: @"%.0f", [root depth]] cString]);	

	e->setMaterialName (materialname);

	Ogre::SceneNode *n2 = n1->createChildSceneNode();
	n2->attachObject (e);
	n2->setInheritScale (false);
	n2->setScale (([root width])/100, .01, ([root height])/100);
	n2->setPosition (0, 0, 0);

//	MovableText *text;
//	text = new MovableText (name, name);
//	text->setColor (Ogre::ColourValue::Blue);
//	text->setCharacterHeight (15);
//	Ogre::SceneNode *textnode = node->createChildSceneNode();
//	textnode->setInheritScale (false);
//	textnode->setPosition ([root x], [root depth], [root y]);
//	textnode->attachObject(text);

        if ([root type] == nil){
                return;
        }
	NSArray *children = [root children];
        if (children != nil){
                unsigned int i;
                for (i = 0; i < [children count]; i++){
                        this->treemapRecursiveDraw ((TrivaTreemap *)[children objectAtIndex: i], n1);
                }
        }
}

void DrawManager::squarifiedTreemapDraw (TrivaTreemapSquarified *root)
{
	try{
		baseSceneNode = currentVisuNode->createChildSceneNode("SquarifiedTreemap");
	}catch (Ogre::Exception ex){
		baseSceneNode = mSceneMgr->getSceneNode ("SquarifiedTreemap");
		baseSceneNode->removeAndDestroyAllChildren();
	}
	this->treemapRecursiveDraw (root, baseSceneNode);
}

void DrawManager::squarifiedTreemapDelete ()
{
	if (baseSceneNode){
		baseSceneNode->removeAndDestroyAllChildren();
		mSceneMgr->destroySceneNode (baseSceneNode->getName());
		baseSceneNode = NULL;
	}
}

void DrawManager::initializeSquarifiedTreemapCategory ()
{
	baseSceneNode = NULL;
}

