#ifndef __DRAW_MANAGER_H
#define __DRAW_MANAGER_H

#include <Ogre.h>
#include <Foundation/Foundation.h>

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
	NSMutableDictionary *createContainersDictionary (id entity);
	void destroyAllChildren (Ogre::SceneNode *node);
	void drawContainers (id entity, Ogre::SceneNode *node);
	void drawTimestampedObjects (id entity);


//MATERIALS CATEGORY
private:
	void createMaterial (std::string materialName, Ogre::ColourValue color);
	Ogre::ColourValue getRegisteredColor (std::string state, std::string value);
public:
	Ogre::ColourValue getMaterialColor (std::string materialName);
	void setMaterialColor (std::string materialName, Ogre::ColourValue og);
	void registerColor (std::string state, std::string value, Ogre::ColourValue col);
};

#include "ProtoView.h"
#include "draw/position/Position.h"
#endif
