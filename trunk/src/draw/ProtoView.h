#ifndef __PROTOVIEW_H
#define __PROTOVIEW_H
#include <Ogre.h>
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "draw/DrawManager.h"

class TrivaColorWindowEvents;

@interface ProtoView  : PajeFilter
{
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;

	DrawManager *drawManager;
}
- (void) initialize;
@end

@interface ProtoView (Materials)
- (void) createMaterialNamed: (NSString *) materialName;
@end

#endif
