#ifndef __DRAW_MANAGER_H
#define __DRAW_MANAGER_H

#include <Ogre.h>
#include <Foundation/Foundation.h>
#include "draw/layout/Layout.h"

@class ProtoView;
@class Position;

class DrawManager : public Ogre::FrameListener,
	public Ogre::WindowEventListener
{
protected:
	bool frameStarted (const Ogre::FrameEvent& evt);
	bool frameEnded (const Ogre::FrameEvent& evt);

	void setStatesVisibility (int k);
	void setContainersVisibility (int k);


private:
	ProtoView *viewController;
	Position *position;

public: 
	DrawManager (ProtoView *view);
	~DrawManager ();
/*
	void movePointer ();
	void updateContainersPositions ();
	void updateContainerDrawings ();
	void updateStatesDrawings ();
	void createStatesDrawings ();
	void updateLinksDrawings ();
	void createLinksDrawings ();

	void changePositionAlgorithm();

	void showStatesLabels ();
	void hideStatesLabels ();
	void showContainersLabels ();
	void hideContainersLabels ();

	//interactive 
//	void selectState (XState *s);
//	void unselectState (XState *s);
*/

private:
	Ogre::Root *mRoot;
	Ogre::SceneManager* mSceneMgr;
	Ogre::AnimationState *mAnimationState;

	Ogre::SceneNode *currentVisuNode;


//PAJE CATEGORY
private:
	LayoutContainer *rootLayout;
	LayoutContainer *internalDrawContainers (id entity, Ogre::SceneNode *node);
	NSMutableDictionary *internalCreateContainersDictionary (id entity);
public:
	void resetCurrentVisualization();
	void createHierarchy ();
	void createTimestampedObjects ();
	
};

#include "ProtoView.h"
#include "draw/position/Position.h"
#endif
