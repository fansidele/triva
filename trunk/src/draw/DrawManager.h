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

	//main scene node of the current visualization,
	//it has two children (baseSceneNode and containerPosition)
	Ogre::SceneNode *currentVisuNode;

	//One scenenode to the visualization base
	Ogre::SceneNode *baseSceneNode;
	//and another to hold containers positions
	Ogre::SceneNode *containerPosition;

//for animations
	void onRenderTimer(wxTimerEvent& evt); //implemnented in DrawManager.mm

//Animation Category
public:
	void moveSceneNodesToNewPositions (
		std::vector<Ogre::SceneNode*> *vectSceneNodesX,
		std::vector<Ogre::Vector3> *vectPosDestX, float animTime);
	Ogre::SceneNode *getOneContainerPosition (id cont,
		Ogre::SceneNode *node, float x,float y,
		std::vector<Ogre::SceneNode*> *vectSceneNodes,
		std::vector<Ogre::Vector3> *PosDestino);
	void applicationAnimatedGraphRecursiveDraw (id entity,
			Position *position, Ogre::SceneNode *node,
			std::vector<Ogre::SceneNode*> *vectSceneNodes,
			std::vector<Ogre::Vector3> *PosDestino);
	void applicationAnimatedGraphDraw (Position *position,
					float animationTime);
	void applicationGraphDrawLines (Position *position);
	void fillVectorSceneNodes (Position *position,
                std::vector<Ogre::SceneNode*> *vectSceneNodes);

	float  avarageDistance(std::vector<Ogre::SceneNode*> vectSceneNodes, Ogre::SceneNode *sceneNodePrinc);
	
	std::vector<Ogre::Vector3> calcNewPositions (std::vector<Ogre::SceneNode*> vectSceneNodes, Ogre::SceneNode *sceneNodePrinc, float varFactorOfDistance, float rayOfAction);
//TIMESTAMPED OBJECTS CATEGORY
public:
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

//PAJE CATEGORY
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
 	void treemapRecursiveDraw (TrivaTreemap *root, Ogre::SceneNode *node);
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
