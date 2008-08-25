#include "DrawManager.h"

void DrawManager::drawOneContainerIntoResourcesGraphBase
                (id entity, Ogre::SceneNode *node, NSPoint loc)
{
	this->drawOneContainer (entity, node, loc.x, loc.y);
}

void DrawManager::resourcesGraphDelete ()
{
	if (baseSceneNode){
		baseSceneNode->removeAndDestroyAllChildren();
		mSceneMgr->destroySceneNode(baseSceneNode->getName());
		baseSceneNode = NULL;
	}
}

void DrawManager::resourcesGraphDraw (TrivaResourcesGraph *graph)
{
	try {
		baseSceneNode = currentVisuNode->createChildSceneNode("ResourcesGraph");
	}catch (Ogre::Exception ex){
		baseSceneNode =  mSceneMgr->getSceneNode ("ResourcesGraph");
		baseSceneNode->removeAndDestroyAllChildren();
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
		Ogre::SceneNode *n1 = baseSceneNode->createChildSceneNode(orname);
		n1->setPosition (x, 0, y);
		Ogre::Entity *e;
		try {
			e = mSceneMgr->getEntity (orname);
		}catch (Ogre::Exception ex){
			e = mSceneMgr->createEntity (orname, 
				Ogre::SceneManager::PT_CUBE);
			e->setMaterialName ("VisuApp/MPI_SEND");
		}
		Ogre::SceneNode *n2 = n1->createChildSceneNode();
		n2->attachObject (e);
		n2->setInheritScale (false);
		n2->setScale ((width*72/100),
					.01,
				(height*72/100));
	}
	ar = [graph allEdges];
	for (i = 0; i < [ar count]; i++){
		NSArray *edge = [ar objectAtIndex: i];
		NSString *head = [edge objectAtIndex: 0];
		NSString *tail = [edge objectAtIndex: 1];

		std::string name = std::string ([head cString]);
		name.append ([tail cString]);

		Ogre::Vector3 op, dp;
		op=mSceneMgr->getSceneNode ([head cString])->getWorldPosition();
		dp=mSceneMgr->getSceneNode ([tail cString])->getWorldPosition();

		Ogre::ManualObject *ste;
		try {
			ste = mSceneMgr->getManualObject (name);
		}catch (Ogre::Exception ex){
			ste = mSceneMgr->createManualObject (name);
		}
		ste->clear();
		ste->begin ("VisuApp/MPI_RECV",
			Ogre::RenderOperation::OT_LINE_STRIP);
		ste->position (op.x, 0, op.z);
		ste->position (dp.x, 0, dp.z);
		ste->end();
 		Ogre::SceneNode *root = mSceneMgr->getRootSceneNode();
		Ogre::SceneNode *n = root->createChildSceneNode();
		try {
			n->attachObject (ste);
		}catch (Ogre::Exception ex){}
	}
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
				NSString *name;
				name = [viewController
					searchRGWithPartialName: [sub name]];
				if (name == nil){
					NSLog (@"ERROR");
				}else{
					Ogre::SceneNode *node;
					node = mSceneMgr->getSceneNode(
						[name cString]);
					NSPoint loc;
					loc = [viewController nextLocationRGForNodeName: name];
					this->drawOneContainerIntoResourcesGraphBase ((id) sub, node, loc);
				}
				this->drawContainersIntoResourcesGraphBase((id)sub);
			}
		}
	}
}

void DrawManager::drawContainersIntoResourcesGraphBase ()
{
        id instance = [viewController rootInstance];
        this->drawContainersIntoResourcesGraphBase (instance);
}
