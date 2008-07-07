#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

void DrawManager::resetCurrentVisualization ()
{
	Ogre::SceneNode *root = mSceneMgr->getRootSceneNode();
	try {
		currentVisuNode = root->createChildSceneNode("CurrentVisu");
	}catch(Ogre::Exception ex){
		//already exists, what to do?
		currentVisuNode = mSceneMgr->getSceneNode ("CurrentVisu");

		//remove everything
		currentVisuNode->removeAndDestroyAllChildren();
	}
}
