#ifndef __LAYOUT_H
#define __LAYOUT_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "draw/extras/MovableText.h"
#include "draw/QueryFlags.h"

@class LayoutContainer;
@class LayoutState;
@class LayoutLink;

@interface Layout : NSObject
{
	LayoutContainer *container;

	Ogre::Entity *entity;
	Ogre::SceneNode *sceneNode;
	Ogre::SceneNode *textNode;
        MovableText *text;
}
- (void) createWithIdentifier: (NSString *) ide andMaterial: (NSString *) mat;
- (Ogre::SceneNode *) attachTo: (Ogre::SceneNode *) node;
- (void) redraw;
- (void) setVisibility: (int) k;
- (void) setSelected: (int) k;
- (Ogre::SceneNode *) sceneNode;
- (void) setPosition: (Ogre::Vector3) vector;
@end

#include "LayoutState.h"
#include "LayoutLink.h"
#include "LayoutContainer.h"
#endif
