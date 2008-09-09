#ifndef __DRAW_MANAGER_H
#define __DRAW_MANAGER_H

#include <Ogre.h>
#include <Foundation/Foundation.h>
#include <General/PajeType.h>
#include "gui/wxInputEventListener.h"
#undef TRUE
#include "TrivaTreemapSquarified.h"
#include "TrivaResourcesGraph.h"

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

//for animations
	void onRenderTimer(wxTimerEvent& evt); //implemnented in DrawManager.mm

//PAJE CATEGORY
public:
//	void createHierarchy ();
	void resetCurrentVisualization();
	void createTimestampedObjects ();

private:
//	NSMutableDictionary *pos;
//	NSMutableDictionary *createContainersDictionary (id entity);
	void destroyAllChildren (Ogre::SceneNode *node);
	void updateLinksPositions ();
	void drawTimestampedObjects (id entity);
	void drawStates (PajeEntityType *et, id container);
	void drawOneState (Ogre::SceneNode *visualContainer, id state);
	void drawLinks (PajeEntityType *et, id container);
	void drawOneLink (id link);

	Ogre::SceneNode *drawOneContainer (id cont, Ogre::SceneNode *node,
					float x,float y);


//MATERIALS CATEGORY
private:
	void createMaterial (std::string materialName, Ogre::ColourValue color);
	Ogre::ColourValue getRegisteredColor (std::string state, std::string value);
public:
	Ogre::ColourValue getMaterialColor (std::string materialName);
	void setMaterialColor (std::string materialName, Ogre::ColourValue og);
	void registerColor (std::string state, std::string value, Ogre::ColourValue col);

// MOUSE CATEGORY
	TrivaController *trivaController;
private:
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

// CATEGORY: ApplicationGraph
	void applicationGraphRecursiveDraw (id entity, Position *position, 
		Ogre::SceneNode *node);
	void applicationGraphDraw (Position *position);

// CATEGORY: SquarifiedTreemap
public:
 	void drawContainersIntoTreemapBase ();
	void squarifiedTreemapDraw (TrivaTreemapSquarified *root);
	void squarifiedTreemapDelete ();
private:
	Ogre::SceneNode *baseSceneNode;
 	void treemapRecursiveDraw (TrivaTreemap *root, Ogre::SceneNode *node);
	void initializeSquarifiedTreemapCategory ();
	void drawContainersIntoTreemapBase (id entity);
	void drawOneContainerIntoTreemapbase (id container, Ogre::SceneNode *n,
			NSPoint loc);

// CATEGORY: ResourcesGraph
public:
	void resourcesGraphDelete ();
	void resourcesGraphDraw (TrivaResourcesGraph *graph);
	void drawContainersIntoResourcesGraphBase ();
	void drawContainersIntoResourcesGraphBase (id entity);
	void drawOneContainerIntoResourcesGraphBase (id container,
		Ogre::SceneNode *n, NSPoint loc);
};

#include "ProtoView.h"
#include "draw/position/Position.h"
#include "gui/TrivaController.h"
#endif
