#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

DrawManager::DrawManager (ProtoView *view) 
{
	viewController = view;
	[viewController retain];

	position = [Position positionWithAlgorithm: @"graphviz"];

	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

	Ogre::SceneNode *root = mSceneMgr->getRootSceneNode();
	Ogre::SceneNode *pointer = root->createChildSceneNode ("pointer");
	Ogre::ManualObject *line = mSceneMgr->createManualObject ("pointer-o");
	line->begin ("VisuApp/XAxis", Ogre::RenderOperation::OT_LINE_LIST);
	line->position (-10,0,-10);
	line->position (-10,0,10);
	line->position (10,0,10);
	line->position (10,0,-10);
	line->end();
	pointer->attachObject (line);

	pointer = root->createChildSceneNode ("pointer2");
	line = mSceneMgr->createManualObject ("pointer2-o");
	line->begin ("VisuApp/YAxis", Ogre::RenderOperation::OT_LINE_LIST);
        line->position (-10,0,-10);
        line->position (-10,0,10);
        line->position (10,0,10);
        line->position (10,0,-10);
        line->end();
        pointer->attachObject (line);

	
	mAnimationState = NULL;

	Ogre::MaterialPtr(Ogre::MaterialManager::getSingleton().getByName("BaseWhiteNoLighting"))->setAmbient(Ogre::ColourValue::Black);
	Ogre::MaterialPtr(Ogre::MaterialManager::getSingleton().getByName("BaseWhiteNoLighting"))->setLightingEnabled(true); 

	//configuring mouse category
	mCurrentObject = NULL;
	mLMouseDown = false;
	mRMouseDown = false;
	mRaySceneQuery = mSceneMgr->createRayQuery(Ogre::Ray());
	this->createMouseCursors();

	/* initialization of main scene nodes */
	currentVisuNode = root->createChildSceneNode("CurrentVisu");

	baseSceneNode = currentVisuNode->createChildSceneNode ("VisuBase");
	containerPosition = currentVisuNode->createChildSceneNode ("ContPosit");
} 

DrawManager::~DrawManager()
{ 
	fprintf (stderr, "DrawManager::%s\n", __FUNCTION__);
	mSceneMgr->clearScene();
	mSceneMgr->destroyAllManualObjects();
	mSceneMgr->destroyAllEntities();
	mSceneMgr->destroyAllCameras();
	Ogre::MaterialManager::getSingleton().removeAll();		
	mRoot->getAutoCreatedWindow()->removeAllViewports();

	//mouse category
	delete mRaySceneQuery;
}

void DrawManager::onRenderTimer(wxTimerEvent& evt)
{
	if (mAnimationState){
		mAnimationState->addTime (evt.GetInterval());
	}
}
