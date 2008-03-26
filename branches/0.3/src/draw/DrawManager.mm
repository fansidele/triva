#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

/*
void DrawManager::setContainersVisibility (int k)
{
	XContainer *root = [viewController root];
	NSArray *ar = [root allContainers];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		[[[ar objectAtIndex: i] layout] setVisibility: k];
	}

}

void DrawManager::setStatesVisibility (int k)
{
	XContainer *root = [viewController root];
	NSArray *ar = [root allContainers];
	unsigned int i, j;
	for (i = 0; i < [ar count]; i++){
		NSArray *ar2 = [[ar objectAtIndex: i] states];
		for (j = 0; j < [ar2 count]; j++){
			[[[ar2 objectAtIndex: j] layout] setVisibility: k];
		}
	}
}

void DrawManager::showStatesLabels ()
{
	this->setStatesVisibility (1);
}


void DrawManager::hideStatesLabels ()
{
	this->setStatesVisibility (0);
}

void DrawManager::showContainersLabels ()
{
	this->setContainersVisibility (1);
}

void DrawManager::hideContainersLabels ()
{
	this->setContainersVisibility (0);
}


void DrawManager::changePositionAlgorithm ()
{
	if ([[position subAlgorithm] isEqual: @"dot"]){
		[position setSubAlgorithm: @"neato"];
	}else if ([[position subAlgorithm] isEqual: @"neato"]){
		[position setSubAlgorithm: @"fdp"];
	}else if ([[position subAlgorithm] isEqual: @"fdp"]){
		[position setSubAlgorithm: @"twopi"];
	}else if ([[position subAlgorithm] isEqual: @"twopi"]){
		[position setSubAlgorithm: @"circo"];
	}else if ([[position subAlgorithm] isEqual: @"circo"]){
		[position setSubAlgorithm: @"dot"];
	}
	this->updateContainersPositions();
}

void DrawManager::updateContainersPositions ()
{
	XContainer *root = [viewController root];
	if (root == NULL){
		return;
	}

	[position newHierarchyOrganization: [viewController hierarchyOrganization]];


	NSDictionary *newLinks = [viewController newLinksBetweenContainers];
	if (newLinks != nil){
		NSArray *allKeys = [newLinks allKeys];
		unsigned int i;
		for (i = 0; i < [allKeys count]; i++){
			NSString *sourceName = [allKeys objectAtIndex: i];
			NSString *destName = [newLinks objectForKey: sourceName];
			[position addLinkBetweenNode: sourceName andNode:
destName];
		}
	}

	NSArray *allContainers = [root allLeafContainers];
	NSMutableDictionary *positions = [position positionForAllNodes];
	unsigned int i;
	for (i = 0; i < [allContainers count]; i++){
		XContainer *cont = [allContainers objectAtIndex: i];
		NSString *ide = [cont identifier];	
		NSArray *nodePos = [positions objectForKey: ide];
		Ogre::Vector3 newPos;
		if ([nodePos count] == 2){
			newPos =  Ogre::Vector3 (Ogre::Real([[nodePos objectAtIndex: 0] doubleValue]), 0, Ogre::Real([[nodePos objectAtIndex: 1] doubleValue]));
		}else{
			newPos =  Ogre::Vector3 (0,0,0);
		}
		[cont setPosition: newPos];
	}





#ifdef OLD_METHOD_USED_WITH_GRAPHVIZ
	NSSet *containersDefined = [NSSet setWithArray: [[position positionForAllNodes] allKeys]];
	NSArray *allContainers = [root allContainers];

	unsigned int i;
	for (i = 0; i < [allContainers count]; i++){
		NSString *contID = (NSString *)[[allContainers objectAtIndex: i] identifier];
		if ([containersDefined member: contID] == nil){
			[position addNode: contID];
		}
	}



	NSMutableDictionary *positions = [position positionForAllNodes];
	for (i = 0; i < [allContainers count]; i++){
		XContainer *cont = [allContainers objectAtIndex: i];
		NSString *ide = [cont identifier];	
		NSArray *nodePos = [positions objectForKey: ide];
		Ogre::Vector3 newPos;
		if ([nodePos count] == 2){
			newPos =  Ogre::Vector3 (Ogre::Real([[nodePos objectAtIndex: 0] doubleValue]), 0, Ogre::Real([[nodePos objectAtIndex: 1] doubleValue]));
		}else{
			newPos =  Ogre::Vector3 (0,0,0);
		}
		[cont setPosition: newPos];
	}
#endif
}

void DrawManager::updateContainerDrawings ()
{
	bool x = [viewController containersLabelsAppearance];
	int visible = (int)x;
	XContainer *root = [viewController root];
	NSMutableArray *ar = [root allContainers];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		XContainer *cont = [ar objectAtIndex: i];
		if (![cont layout]){
			LayoutContainer *lay = [[LayoutContainer alloc] init];
			[cont setLayout: lay];
			[lay setVisibility: visible];
		}
	}
}

void DrawManager::createStatesDrawings ()
{
	bool x = [viewController statesLabelsAppearance];
	int visible = (int)x;
	XContainer *root = [viewController root];
	NSMutableArray *ar = [root allContainersWithStates];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		XContainer *cont = [ar objectAtIndex: i];
		NSArray *states = [cont states];
		int j;
		for (j = [states count] - 1; j >= 0; j--){
			XState *state = [states objectAtIndex: j];
			if (![state layout]){
				LayoutState *lay = [[LayoutState alloc] init];
				[state setLayout: lay];
				[lay setVisibility: visible];
			}
		}
	}
}

void DrawManager::updateStatesDrawings ()
{
	bool x = [viewController statesLabelsAppearance];
	int visible = (int)x;
	XContainer *root = [viewController root];
	NSMutableArray *ar = [root allContainersWithStates];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		XContainer *cont = [ar objectAtIndex: i];
		NSArray *states = [cont states];
		int j;
		for (j = [states count] - 1; j >= 0; j--){
			XState *state = [states objectAtIndex: j];
//			if ([state finalized] == NO){
				[state updateLayout];
//			}	
			[[state layout] setVisibility: visible];
		}
	}
}

void DrawManager::createLinksDrawings ()
{
	XContainer *root = [viewController root];
	NSMutableArray *ar = [root allContainersWithFinalizedLinks];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		XLink *link = (XLink *)[ar objectAtIndex: i];
		if (![link layout]){
			LayoutLink *lay = [[LayoutLink alloc] init];
			[link setLayout: lay];
		}
	}
}

void DrawManager::updateLinksDrawings ()
{
	XContainer *root = [viewController root];
	NSMutableArray *ar = [root allContainersWithFinalizedLinks];
	unsigned int i;
	for (i = 0; i < [ar count]; i++){
		XLink *link = (XLink *)[ar objectAtIndex: i];
		[link updateLayout];
		if (![link layout]){
			LayoutLink *lay = [[LayoutLink alloc] init];
			[link setLayout: lay];
		}
	}
}
*/

/*
#define ANIMTIME 0.15

void DrawManager::movePointer ()
{
	static Ogre::Real saved = 0;
	std::string x = [[viewController endTime] cString];
	Ogre::Real end = Ogre::Real (atof(x.c_str()));
	Ogre::SceneNode *pointer = mSceneMgr->getSceneNode ("pointer2");
	pointer->setPosition (0,end,0);
	pointer = mSceneMgr->getSceneNode ("pointer");

	if (mAnimationState != NULL) { 
		if (mAnimationState->getTimePosition() < ANIMTIME){
			saved = end;
			return;
		}
	}

	Ogre::Vector3 nowPos = pointer->getPosition ();
	Ogre::Real start = nowPos.y;

	Ogre::NodeAnimationTrack *track;
	Ogre::TransformKeyFrame *key;
	Ogre::Animation *anim;
        try {
		anim = mSceneMgr->createAnimation ("pointer-t", ANIMTIME);
        }catch (Ogre::Exception &ex){
		mSceneMgr->destroyAnimationState ("pointer-t");
		mAnimationState = NULL;
		mSceneMgr->destroyAnimation ("pointer-t");
		anim = mSceneMgr->createAnimation ("pointer-t", ANIMTIME);
	}
	anim->setInterpolationMode(Ogre::Animation::IM_SPLINE);
	track = anim->createNodeTrack(0, pointer);
	key = track->createNodeKeyFrame (0);
	key->setTranslate (Ogre::Vector3 (0,start,0));
	key = track->createNodeKeyFrame (ANIMTIME);
	key->setTranslate (Ogre::Vector3 (0,end,0));

	mAnimationState	= mSceneMgr->createAnimationState("pointer-t");
	mAnimationState->setEnabled (true);
	mAnimationState->setLoop (false);
}
*/

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

	
	currentVisuNode = NULL;
	mAnimationState = NULL;

	Ogre::MaterialPtr(Ogre::MaterialManager::getSingleton().getByName("BaseWhiteNoLighting"))->setAmbient(Ogre::ColourValue::Black);
	Ogre::MaterialPtr(Ogre::MaterialManager::getSingleton().getByName("BaseWhiteNoLighting"))->setLightingEnabled(true); 

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
}

bool DrawManager::frameEnded (const Ogre::FrameEvent& evt) 
{
	return true; 
} 


bool DrawManager::frameStarted (const Ogre::FrameEvent& evt) 
{ 
	if (mAnimationState != NULL){
		mAnimationState->addTime(evt.timeSinceLastFrame);
	}
	return true; 
} 


/*
void DrawManager::selectState (XState *s)
{
	[[s layout] setSelected: 1];
}

void DrawManager::unselectState (XState *s)
{
	[[s layout] setSelected: 0];
}
*/
