#ifndef __DRAW_MANAGER_H
#define __DRAW_MANAGER_H

#include <Ogre.h>
#include <Foundation/Foundation.h>
#include <General/PajeType.h>
#include "gui/wxInputEventListener.h"
#include "TrivaTreemapSquarified.h"

class TrivaController;
@class ProtoView;
@class Position;

class DrawManager : public wxInputEventListener
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

private:
	Ogre::Root *mRoot;
	Ogre::SceneManager* mSceneMgr;
	Ogre::AnimationState *mAnimationState;

	Ogre::SceneNode *currentVisuNode;


//PAJE CATEGORY
public:
	void createHierarchy ();
	void resetCurrentVisualization();
	void createTimestampedObjects ();

private:
	NSMutableDictionary *pos;
	NSMutableDictionary *createContainersDictionary (id entity);
	void destroyAllChildren (Ogre::SceneNode *node);
	void drawContainers (id entity, Ogre::SceneNode *node);
	void updateLinksPositions ();
	void updateLinksPositions (id entity);
	void updateLinksPositions (PajeEntityType *et, id container);
	void drawTimestampedObjects (id entity);
	void drawStates (PajeEntityType *et, id container);
	void drawLinks (PajeEntityType *et, id container);


//MATERIALS CATEGORY
private:
	void createMaterial (std::string materialName, Ogre::ColourValue color);
	Ogre::ColourValue getRegisteredColor (std::string state, std::string value);
public:
	Ogre::ColourValue getMaterialColor (std::string materialName);
	void setMaterialColor (std::string materialName, Ogre::ColourValue og);
	void registerColor (std::string state, std::string value, Ogre::ColourValue col);

// MOUSE CATEGORY
private:
	TrivaController *trivaController;
	Ogre::RaySceneQuery *mRaySceneQuery;
	Ogre::MovableObject *mCurrentObject;
	bool mLMouseDown, mRMouseDown;
	std::vector<Ogre::MovableObject*> containersSelected;
protected:
	void selectObject (wxMouseEvent& evt, unsigned int mask);
	void moveObject (wxMouseEvent& evt);
	void moveMouseCursors (wxMouseEvent& evt);
	void createMouseCursors ();
        void onMouseEvent(wxMouseEvent& evt);
	void onKeyDownEvent(wxKeyEvent& evt);
public:
	void setTrivaController (TrivaController *triva);

// (VISUALIZATION) BASE CATEGORY
 	void treemapRecursiveDraw (TrivaTreemap *root, Ogre::SceneNode *node);
	void squarifiedTreemapDraw (TrivaTreemapSquarified *root);
	Ogre::SceneNode *baseSceneNode;
	void initializeBaseCategory ();

// CATEGORY: Squarified (functions to draw applic. data over a treemap base)
public:
 	void drawContainersIntoTreemapBase ();
private:
	void drawContainersIntoTreemapBase (id entity);
	void drawOneContainerIntoTreemapbase (id container, Ogre::SceneNode *n,
			NSPoint loc);

};

#include "ProtoView.h"
#include "draw/position/Position.h"
#include "gui/TrivaController.h"
#endif
