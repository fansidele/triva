#ifndef __PROTOVIEW_H
#define __PROTOVIEW_H
#include <Ogre.h>
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "draw/DrawManager.h"

@interface ProtoView  : PajeFilter
{
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;

	DrawManager *drawManager;
}
- (DrawManager *) drawManager;
@end

@interface ProtoView (Materials)
- (void) createMaterialNamed: (NSString *) materialName;
@end

@interface ProtoView (Base)
- (BOOL) squarifiedTreemapWithFile: (NSString *) file;
- (BOOL) originalTreemapWithFile: (NSString *) file;
@end

#endif
