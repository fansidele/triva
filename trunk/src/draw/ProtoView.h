#ifndef __PROTOVIEW_H
#define __PROTOVIEW_H
#include <Ogre.h>
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "draw/DrawManager.h"
#include "TrivaTreemapSquarified.h"
#include "TrivaResourcesGraph.h"

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
	TrivaResourcesGraph *resourcesGraph;

	//variables to bse used by Base category - application graph
	Position *applicationGraphPosition;

	double pointsPerSecond;
}
- (DrawManager *) drawManager;
- (void) setPointsPerSecond: (double) nv;
- (double) pointsPerSecond;
- (void) updateScrollbar;
@end

@interface ProtoView (Materials)
- (void) createMaterialNamed: (NSString *) materialName;
@end

@interface ProtoView (Base)
- (BOOL) squarifiedTreemapWithFile: (NSString *) file
	andWidth: (float) w andHeight: (float) h;
- (BOOL) originalTreemapWithFile: (NSString *) file;
- (BOOL) resourcesGraphWithFile: (NSString *) file
		andGraphvizAlgorithm: (NSString *) algo;
- (BOOL) applicationGraph;
- (void) disableVisualizationBase: (TrivaVisualizationBaseState) baseCode;

//to interact with the squarifiedTreemap objects
- (TrivaTreemap *) searchWithPartialName: (NSString *) partialName;

//to call methods of previous paje filters
- (void) recalculateSquarifiedTreemapWithApplicationData;

//to application graph
- (NSMutableDictionary *) dictionaryForApplicationGraph: (id) entity;
- (void) recalculateApplicationGraphWithApplicationData;

//resources graph
- (void) recalculateResourcesGraphWithApplicationData;
- (void) recalculateResourcesGraphWith: (id) entity;
@end

#endif
