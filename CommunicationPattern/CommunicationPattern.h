#ifndef __COMMPATVIEW_H
#define __COMMPATVIEW_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <Ogre.h>
#include "DrawManager.h"

@interface CommunicationPattern  : PajeFilter
{
	/* for ProtoView category */
	Ogre::Root *mRoot;
	Ogre::RenderWindow *mWindow;
	Ogre::SceneManager *mSceneMgr;

	DrawManager *drawManager;

	Position *applicationGraphPosition;
	double pointsPerSecond;
	NSDictionary *entityTypesChosen; /* set by GUI_CombinedCounter */
}
- (BOOL) setupResources;
- (BOOL) configureOgre;
- (void) initializeResources;
@end

@interface CommunicationPattern (ProtoView)
- (DrawManager *) drawManager;
- (void) setPointsPerSecond: (double) nv;
- (double) pointsPerSecond;
- (Position *) getApplicationGraphPosition;
@end

@interface CommunicationPattern (ProtoViewBase)
- (BOOL) applicationGraphWithAlgorithm: (NSString *) algo;
- (BOOL) mustDrawContainer: (id) container;

//to call methods of previous paje filters
- (void) recalculateSquarifiedTreemapWithApplicationData;

//to application graph
- (NSMutableDictionary *) dictionaryForApplicationGraph: (id) entity;
- (void) recalculateApplicationGraphWithApplicationData;
@end

#endif
