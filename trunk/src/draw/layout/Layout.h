#ifndef __LAYOUT_H
#define __LAYOUT_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "draw/extras/MovableText.h"
#include "draw/QueryFlags.h"

@interface Layout : NSObject
{
	Ogre::Entity *entity;
	Ogre::SceneNode *sceneNode;
	Ogre::SceneNode *textNode;
        MovableText *text;
}
- (void) createWithIdentifier: (NSString *) ide andMaterial: (NSString *) mat;
- (void) attachTo: (Ogre::SceneNode *) node;
- (void) redraw;
- (void) setVisibility: (int) k;
- (void) setSelected: (int) k;
@end

#include "LayoutState.h"
#include "LayoutLink.h"
#include "LayoutContainer.h"
#endif
