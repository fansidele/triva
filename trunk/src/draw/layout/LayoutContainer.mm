#include "LayoutContainer.h"

@implementation LayoutContainer
- (id) init
{
	self = [super init];
	subcontainers = [NSMutableArray array];
	states = [NSMutableArray array];
	return self;
}

- (void) dealloc
{
	[subcontainers release];
	[states release];
	[super dealloc];
}

- (void) createWithIdentifier: (NSString *) ide andMaterial: (NSString *) t
{
	Ogre::Root *mRoot = Ogre::Root::getSingletonPtr();
	Ogre::SceneManager * mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

//	std::string materialName;
//	materialName.append("VisuApp/");
//	materialName.append([t cString]);

	entity = mSceneMgr->createEntity ([ide cString], Ogre::SceneManager::PT_CUBE);
	entity->setMaterialName ("VisuApp/Base");
	entity->setQueryFlags(CONTAINER_MASK);

	text = new MovableText ([ide cString], [ide cString]);
	text->setColor (Ogre::ColourValue::Blue);
	text->setCharacterHeight (15);
}

- (Ogre::SceneNode *) attachTo: (Ogre::SceneNode *) node
{
	[super attachTo: node];
	sceneNode->setScale (.3,.01,.3);
	sceneNode->setInheritScale (false); // just for container
	return sceneNode;
}

- (void) addSubContainer: (LayoutContainer *) lc
{
	[subcontainers addObject: lc];
}

- (void) addState: (LayoutState *) ls
{
	[states addObject: ls];
}
@end
