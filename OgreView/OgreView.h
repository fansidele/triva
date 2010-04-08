#ifndef __OGREVIEW_H
#define __OGREVIEW_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <Ogre.h>
#include "DrawManager.h"
#include "TrivaTreemapSquarified.h"
#include "TrivaResourcesGraph.h"

enum TrivaVisualizationBaseState {
        SquarifiedTreemap,
        OriginalTreemap,
        ResourcesGraph,
        ApplicationGraph };

@interface OgreView  : PajeFilter
{
	/* for ProtoView category */
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;

	DrawManager *drawManager;

	TrivaVisualizationBaseState baseState;
	TrivaTreemapSquarified *squarifiedTreemap;
	TrivaResourcesGraph *resourcesGraph;

	Position *applicationGraphPosition;
	double pointsPerSecond;
	NSDictionary *entityTypesChosen; /* set by GUI_CombinedCounter */
}
- (BOOL) setupResources;
- (BOOL) configureOgre;
- (void) initializeResources;
@end

@interface OgreView (ProtoView)
- (DrawManager *) drawManager;
- (void) setPointsPerSecond: (double) nv;
- (double) pointsPerSecond;
- (Position *) getApplicationGraphPosition;
- (NSDate *) globalStartTime;
- (NSDate *) globalEndTime;
@end

@interface OgreView (ProtoViewBase)
- (void) setCombinedCounterConfiguration: (NSDictionary *) d;
- (BOOL) squarifiedTreemapWithFile: (NSString *) file
        andWidth: (float) w andHeight: (float) h;
- (BOOL) originalTreemapWithFile: (NSString *) file;
- (BOOL) resourcesGraphWithFile: (NSString *) file
                andSize: (NSString *) size
                andSeparationRate: (NSString *) sep
                andGraphvizAlgorithm: (NSString *) algo;
- (BOOL) applicationGraphWithSize: (NSString *) sizeStr andGraphvizAlgorithm:
  (NSString *) algo;
- (void) disableVisualizationBase: (TrivaVisualizationBaseState) baseCode;
- (BOOL) mustDrawContainer: (id) container;

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
- (NSString *) searchRGWithPartialName: (NSString *) partialName;
- (NSPoint) nextLocationRGForNodeName: (NSString *) nodeName;
@end

#endif
