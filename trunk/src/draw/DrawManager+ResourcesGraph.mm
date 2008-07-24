#include "DrawManager.h"


void DrawManager::resourcesGraphDraw (TrivaResourcesGraph *graph)
{
	Ogre::SceneNode *resourcesGraphSceneNode;
	try {
		resourcesGraphSceneNode = currentVisuNode->createChildSceneNode("ResourcesGraph");
	}catch (Ogre::Exception ex){
		resourcesGraphSceneNode =  mSceneMgr->getSceneNode ("ResourcesGraph");
		resourcesGraphSceneNode->removeAndDestroyAllChildren();
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
		Ogre::SceneNode *n1 = resourcesGraphSceneNode->createChildSceneNode(orname);
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
		n2->setScale ((width/100)*10,
					.01,
				(height/100)*10);
	}
}
