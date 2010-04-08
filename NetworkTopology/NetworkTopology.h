#ifndef __NETTOP_H
#define __NETTOP_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <Ogre.h>
#include "DrawManager.h"
#include "TrivaTreemapSquarified.h"
#include "TrivaResourcesGraph.h"

@interface NetworkTopology  : PajeFilter
{
	/* for ProtoView category */
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;

	DrawManager *drawManager;

	TrivaResourcesGraph *resourcesGraph;

	Position *applicationGraphPosition;
	double pointsPerSecond;
	NSDictionary *entityTypesChosen; /* set by GUI_CombinedCounter */
}
- (BOOL) setupResources;
- (BOOL) configureOgre;
- (void) initializeResources;
@end

@interface NetworkTopology (ProtoView)
- (DrawManager *) drawManager;
- (void) setPointsPerSecond: (double) nv;
- (double) pointsPerSecond;
- (Position *) getApplicationGraphPosition;
- (NSDate *) globalStartTime;
- (NSDate *) globalEndTime;
@end

@interface NetworkTopology (ProtoViewBase)
- (BOOL) resourcesGraphWithFile: (NSString *) file
                andSize: (NSString *) size
                andSeparationRate: (NSString *) sep
                andGraphvizAlgorithm: (NSString *) algo;
- (BOOL) mustDrawContainer: (id) container;

//resources graph
- (void) recalculateResourcesGraphWithApplicationData;
- (void) recalculateResourcesGraphWith: (id) entity;
- (NSString *) searchRGWithPartialName: (NSString *) partialName;
- (NSPoint) nextLocationRGForNodeName: (NSString *) nodeName;
@end

#endif
