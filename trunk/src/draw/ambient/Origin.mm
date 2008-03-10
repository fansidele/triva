#include "Origin.h"

Origin::Origin (Ogre::SceneNode *parent) 
{
	sceneMgr = parent->getCreator();
	node = parent->createChildSceneNode ("Origin");
//	node->setInheritScale (false);
};
