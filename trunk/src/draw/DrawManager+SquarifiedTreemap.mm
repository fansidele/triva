#include "DrawManager.h"

void DrawManager::drawContainersIntoTreemapBase ()
{
	id instance = [viewController rootInstance];
	this->drawContainersIntoTreemapBase (instance);
}

void DrawManager::drawOneContainerIntoTreemapbase 
		(id entity, Ogre::SceneNode *node, NSPoint loc)
{
	Ogre::Vector3 relLocation (loc.x, 0, loc.y);
	Ogre::Vector3 nodeLocation = node->_getDerivedPosition();
	Ogre::Vector3 r = nodeLocation+relLocation;
	this->drawOneContainer (entity, containerPosition, r.x, r.z);
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

	NSString *squareId, *squareDrawingId;

	squareId = [root name];
	squareDrawingId = [NSString stringWithFormat: @"%@-draw", squareId];

	std::string orname = std::string ([squareId cString]);
	Ogre::SceneNode *n1;
	try {
		n1 = mSceneMgr->getSceneNode(orname);
	}catch (Ogre::Exception ex){
		n1 = node->createChildSceneNode(orname);
	}
	n1->setPosition ([root x], .10, [root y]);

	Ogre::Entity *e;
	try {
		e = mSceneMgr->getEntity ([squareId cString]);
	}catch (Ogre::Exception ex){
		e = mSceneMgr->createEntity ([squareId cString],
				Ogre::SceneManager::PT_CUBE);

		std::string materialname = "Triva/Treemap/";
		materialname.append ([[NSString stringWithFormat: @"%.0f", [root depth]] cString]);	
		e->setMaterialName (materialname);
	}

	Ogre::SceneNode *n2;
	try {
		n2 = mSceneMgr->getSceneNode ([squareDrawingId cString]);
	} catch (Ogre::Exception ex){
		n2 = n1->createChildSceneNode([squareDrawingId cString]);
		n2->attachObject (e);
		n2->setInheritScale (false);
		n2->setPosition (0, 0, 0);
	}
	n2->setScale ((([root width])/100)-([root depth]*.05),
			.01,
			((([root height])/100))-([root depth]*.05));

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
	Ogre::SceneNode *node;
	try{
		node = baseSceneNode->createChildSceneNode("SquarifiedTreemap");
	}catch (Ogre::Exception ex){
		node = mSceneMgr->getSceneNode ("SquarifiedTreemap");
		node->removeAndDestroyAllChildren();
	}
	this->treemapRecursiveDraw (root, node);
}

void DrawManager::squarifiedTreemapDelete ()
{
	Ogre::SceneNode *node;
	try {
		node = mSceneMgr->getSceneNode ("SquarifiedTreemap");
		node->removeAndDestroyAllChildren();
		mSceneMgr->destroySceneNode ("SquarifiedTreemap");
	}catch (Ogre::Exception ex){}
}
