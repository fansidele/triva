#ifndef __PROTOVIEW_H
#define __PROTOVIEW_H
#include <Ogre.h>
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "draw/DrawManager.h"
#include "TrivaTreemapSquarified.h"

//which method to be used in the Base category
enum TrivaVisualizationBaseState {
	SquarifiedTreemap, 
	OriginalTreemap,
	ResourcesGraph,
	ApplicationGraph };

@interface ProtoView  : PajeFilter
{
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;

	DrawManager *drawManager;

	//variables to be used by Base category
	TrivaVisualizationBaseState baseState;	
	TrivaTreemapSquarified *squarifiedTreemap;
}
- (DrawManager *) drawManager;
@end

@interface ProtoView (Materials)
- (void) createMaterialNamed: (NSString *) materialName;
@end

@interface ProtoView (Base)
- (BOOL) squarifiedTreemapWithFile: (NSString *) file;
- (BOOL) originalTreemapWithFile: (NSString *) file;
- (BOOL) resourcesGraphWithFile: (NSString *) file;
- (BOOL) applicationGraph;
- (void) disableVisualizationBase: (TrivaVisualizationBaseState) baseCode;
- (TrivaTreemap *) searchWithPartialName: (NSString *) partialName;
@end

#endif
