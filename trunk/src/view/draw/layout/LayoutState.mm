#include "LayoutState.h"

@implementation LayoutState
- (id) init
{
	self = [super init];
	start = end = 0;
	return self;
}
- (void) createWithIdentifier: (NSString *) ide andMaterial: (NSString *) mat
{
	Ogre::Root *mRoot = Ogre::Root::getSingletonPtr();
	Ogre::SceneManager * mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	
	std::string materialName;
	materialName.append("VisuApp/");
	materialName.append([mat cString]);
	
	entity = mSceneMgr->createEntity ([ide cString], Ogre::SceneManager::PT_CUBE);
	entity->setMaterialName (materialName);
	
	text = new MovableText ([mat cString], [mat cString]);
	text->setColor (Ogre::ColourValue::Blue);
	text->setCharacterHeight (15);
}

- (void) attachTo: (Ogre::SceneNode *) node
{
	[super attachTo: node];
	sceneNode->setScale (0,0,0);
	sceneNode->setPosition (0,0,0);
}

- (void) setStart: (double) s
{
	start = s;
}

- (void) setEnd: (double) e
{
	end = e;
}

- (void) redraw
{
	if (start == 0 && end == 0){
		NSLog (@"warning: start = 0 end = 0 at %@", self);
		sceneNode->setPosition (0,0,0);
		sceneNode->setScale (0,0,0);
	}else{
//		NSLog (@"%@: %f -> %f", self, start, end);
		sceneNode->setPosition (0,(end-start)/2+start,0);
		sceneNode->setScale (0.3,(end-start)/100,0.3);
	}
}
@end
