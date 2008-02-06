#ifndef __LAYOUT_H
#define __LAYOUT_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "view/extras/MovableText.h"
#include "view/QueryFlags.h"

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
@end

#include "view/draw/layout/LayoutState.h"
#include "view/draw/layout/LayoutLink.h"
#include "view/draw/layout/LayoutContainer.h"
#endif
