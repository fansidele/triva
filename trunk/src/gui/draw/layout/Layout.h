#ifndef __LAYOUT_H
#define __LAYOUT_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "gui/extras/MovableText.h"
#include "gui/QueryFlags.h"

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

#include "gui/draw/layout/LayoutState.h"
#include "gui/draw/layout/LayoutLink.h"
#include "gui/draw/layout/LayoutContainer.h"
#endif
