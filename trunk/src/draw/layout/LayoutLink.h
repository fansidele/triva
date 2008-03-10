#ifndef __LAYOUTLINK_H
#define __LAYOUTLINK_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "gui/draw/layout/Layout.h"
#include "gui/extras/DynamicLines.h"

@interface LayoutLink : Layout
{
//	Ogre::ManualObject *line;
	DynamicLines *line;

	Ogre::Entity *startBall, *endBall;
	Ogre::SceneNode *startBallSceneNode;
	Ogre::SceneNode *endBallSceneNode;

	double start;
	double end;
	double sourceX, sourceZ, destX, destZ;
}
- (void) setStart: (double) s;
- (void) setEnd: (double) e;
- (void) setSourceX: (double) x andZ: (double) z;
- (void) setDestX: (double) x andZ: (double) z;
@end

#endif
