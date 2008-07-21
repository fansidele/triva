#include "DrawManager.h"

void DrawManager::drawContainersIntoTreemapBase ()
{
	id instance = [viewController rootInstance];
	this->drawContainersIntoTreemapBase (instance);
}

void DrawManager::drawOneContainerIntoTreemapbase 
		(id entity, Ogre::SceneNode *node, NSPoint loc)
{
	this->drawOneContainer (entity, node, loc.x, loc.y);
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
std::cout << orname << " width: " << (([root width])/100)*.9 << std::endl;
	n2->setScale ((([root width])/100)-([root depth]*.05),
			.01,
			((([root height])/100))-([root depth]*.05));
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

