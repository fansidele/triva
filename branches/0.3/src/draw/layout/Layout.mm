#include "Layout.h"

@implementation Layout
- (id) init
{
	self = [super init];
	entity = NULL;
	sceneNode = NULL;
	return self;
}

- (void) setVisibility: (int) k
{
	if (k){
		textNode->setVisible (true);
	}else{
		textNode->setVisible (false);
	}
}

- (void) redraw
{
//subclasses
}

- (Ogre::SceneNode *) attachTo: (Ogre::SceneNode *) node
{
	if (entity != NULL){
		if (sceneNode == NULL){
			sceneNode = node->createChildSceneNode();
			sceneNode->attachObject (entity);
			textNode = sceneNode->createChildSceneNode();
			textNode->attachObject (text);
			textNode->setInheritScale (false);
		}
	}
	return sceneNode;
}

- (void) createWithIdentifier: (NSString *) ide andMaterial: (NSString *) t
{
	NSString *str;
	str = [NSString stringWithFormat: @"%@: createWithIdentifier must be implemented in the subclasses", self];
	[[NSException exceptionWithName: @"Layout"  reason: str userInfo: nil]
raise];
}

- (void) setSelected: (int) k
{
	if (k){
		sceneNode->showBoundingBox (true);
	}else{
		sceneNode->showBoundingBox (false);

	}
}

- (Ogre::SceneNode *) sceneNode
{
	return sceneNode;
}

- (void) setPosition: (Ogre::Vector3) vector
{
	sceneNode->setPosition (vector);
}
@end
