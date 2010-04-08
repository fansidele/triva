#include "DrawManager.h"

void DrawManager::drawOneContainerIntoResourcesGraphBase
                (id entity, Ogre::SceneNode *node, NSPoint loc)
{
        Ogre::Vector3 relLocation (loc.x, 0, loc.y);
#if OGRE_VERSION_MAJOR == 1 && OGRE_VERSION_MINOR == 6
        Ogre::Vector3 nodeLocation = node->_getDerivedPosition();
#else
	Ogre::Vector3 nodeLocation = node->getWorldPosition();
#endif
        Ogre::Vector3 r = nodeLocation+relLocation;
	this->drawOneContainer (entity, containerPosition, r.x, r.z);
}

void DrawManager::resourcesGraphDelete ()
{
	Ogre::SceneNode *node;
	try {
		node = mSceneMgr->getSceneNode ("ResourcesGraph");
		node->removeAndDestroyAllChildren();
		mSceneMgr->destroySceneNode ("ResourcesGraph");
	}catch(Ogre::Exception ex){}
}

void DrawManager::resourcesGraphDrawLinks (TrivaResourcesGraph *graph)
{
	Ogre::SceneNode *node =  mSceneMgr->getSceneNode ("ResourcesGraph");
	int i;
	NSArray *ar = [graph allEdges];
	for (i = 0; i < [ar count]; i++){
		NSArray *edge = [ar objectAtIndex: i];
		NSString *head = [edge objectAtIndex: 0];
		NSString *tail = [edge objectAtIndex: 1];

		std::string name = std::string ([head cString]);
		name.append ([tail cString]);

		Ogre::Vector3 op, dp;
#if OGRE_VERSION_MAJOR == 1 && OGRE_VERSION_MINOR == 6
		op=mSceneMgr->getSceneNode ([head cString])->_getDerivedPosition();
		dp=mSceneMgr->getSceneNode ([tail cString])->_getDerivedPosition();
#else
		op=mSceneMgr->getSceneNode ([head cString])->getWorldPosition();
		dp=mSceneMgr->getSceneNode ([tail cString])->getWorldPosition();
#endif

		Ogre::ManualObject *ste;
		try {
			ste = mSceneMgr->getManualObject (name);
		}catch (Ogre::Exception ex){
			ste = mSceneMgr->createManualObject (name);
		}
		ste->clear();
		ste->begin ("VisuApp/ResourcesGraphEdge",
			Ogre::RenderOperation::OT_LINE_STRIP);
		ste->position (op.x, -5, op.z);
		ste->position (dp.x, -5, dp.z);
		ste->end();
 //		Ogre::SceneNode *root = mSceneMgr->getRootSceneNode();
//		Ogre::SceneNode *n = root->createChildSceneNode();
		try {
			node->attachObject (ste);
		}catch (Ogre::Exception ex){}
	}

}

void DrawManager::resourcesGraphDraw (TrivaResourcesGraph *graph)
{
	Ogre::SceneNode *node;
	try {
		node = baseSceneNode->createChildSceneNode("ResourcesGraph");
	}catch (Ogre::Exception ex){
		node =  mSceneMgr->getSceneNode ("ResourcesGraph");
		node->removeAndDestroyAllChildren();
	}

	NSArray *ar = [graph allNodes];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		NSString *nodeName = [ar objectAtIndex: i];
		int x = [graph positionXForNode: nodeName];
		int y = [graph positionYForNode: nodeName];
		float width = (float)[graph widthForNode: nodeName];
		float height = (float)[graph heightForNode: nodeName];

		std::string orname = std::string ([nodeName cString]);
		Ogre::SceneNode *n1 = node->createChildSceneNode(orname);
		n1->setPosition (x, -4, y);
		Ogre::Entity *e;
		try {
			e = mSceneMgr->getEntity (orname);
		}catch (Ogre::Exception ex){
			e = mSceneMgr->createEntity (orname, 
				Ogre::SceneManager::PT_CUBE);
			e->setMaterialName ("Triva/ResourcesGraphNode");
			e->setQueryFlags (RESOURCE_GRAPH_MASK);
		}
		/* TODO: next function probably causes memory leak */
		Ogre::SceneNode *n2 = n1->createChildSceneNode();
		n2->attachObject (e);
		n2->setInheritScale (false);
		n2->setScale ((width*72/100),
					.01,
				(height*72/100));
		n2->showBoundingBox(true);
	}
	this->resourcesGraphDrawLinks (graph);
}

void DrawManager::drawContainersIntoResourcesGraphBase (id entity)
{
        PajeEntityType *et;
	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity: entity]] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			PajeContainer *sub;
			NSEnumerator *en2 = [viewController enumeratorOfContainersTyped:et inContainer: entity];
			while ((sub = [en2 nextObject]) != nil) {
				if ([viewController mustDrawContainer: sub]){
					NSString *name;
					name = [viewController
						searchRGWithPartialName: [sub name]];
					if (name == nil){
						NSLog (@"ERROR with name =%@",
[sub name]);
					}else{
						//NSLog (@"Will draw %@", [sub name]);
						Ogre::SceneNode *node;
						node = mSceneMgr->getSceneNode(
							[name cString]);
						NSPoint loc;
						loc = [viewController nextLocationRGForNodeName: name];
						this->drawOneContainerIntoResourcesGraphBase ((id) sub, node, loc);
					}
				}else{
					this->drawContainersIntoResourcesGraphBase((id)sub);
				}

			}
		}
	}
}

void DrawManager::drawContainersIntoResourcesGraphBase ()
{
        id instance = [viewController rootInstance];
        this->drawContainersIntoResourcesGraphBase (instance);
}