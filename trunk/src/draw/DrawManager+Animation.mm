#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"
#include "TrivaTreemapSquarified.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

//move sceneNodes from vectSceneNodesX to postions at vectPosDestX
void DrawManager::moveSceneNodesToNewPositions (std::vector<Ogre::SceneNode*> *vectSceneNodesX, std::vector<Ogre::Vector3> *vectPosDestX, float animTime)
{ 
        Ogre::Root *mRootX;
        mRootX = Ogre::Root::getSingletonPtr();

        Ogre::SceneManager *sceneMgrX;
        sceneMgrX = mRootX->getSceneManager("VisuSceneManager");
        Ogre::Vector3 iniPos;
        Ogre::SceneNode *varCubeSceneNodeX;
        std::vector<Ogre::Vector3> vectIniPos;

        unsigned int i = 0;

	//get the initial positions of the SceneNodes e put in vectIniPos
        for (i=0; i <= vectSceneNodesX->size() - 1; i++){
                varCubeSceneNodeX = vectSceneNodesX->at(i);
                iniPos = varCubeSceneNodeX->getPosition();
                vectIniPos.push_back(iniPos);
        }

        Ogre::SceneNode *cubeSceneNode;
        Ogre::TransformKeyFrame* keySceneNode;
        Ogre::Animation *mainAnim;
        Ogre::NodeAnimationTrack *varTrackCube;

	try {
		mainAnim = sceneMgrX->getAnimation("ApplicationGraphAnimation");
		sceneMgrX->destroyAnimation("ApplicationGraphAnimation");
	}catch (Ogre::Exception ex){
		//do nothing
	}

        mainAnim = sceneMgrX->createAnimation("ApplicationGraphAnimation",
						animTime);
        mainAnim->setInterpolationMode (Ogre::Animation::IM_SPLINE);
        for (i = 0; i <= vectIniPos.size() - 1; i++ ){
                cubeSceneNode = vectSceneNodesX->at(i);
                varTrackCube = mainAnim->createNodeTrack (i, cubeSceneNode);

                keySceneNode = varTrackCube->createNodeKeyFrame(0);
                keySceneNode->setTranslate(vectIniPos.at(i));

                keySceneNode = varTrackCube->createNodeKeyFrame(animTime);
                keySceneNode->setTranslate(vectPosDestX->at(i));
        }
	mAnimationState=sceneMgrX->createAnimationState
					("ApplicationGraphAnimation");
	mAnimationState->setEnabled(true);
	mAnimationState->setLoop(false);
        return;
}


//put container's sceneNode and positions in the vectors for the animation
Ogre::SceneNode *DrawManager::getOneContainerPosition (id cont,
	Ogre::SceneNode *node, float x, float y,
	std::vector<Ogre::SceneNode*> *vectSceneNodes,
	std::vector<Ogre::Vector3> *PosDestino)
{  
	std::string orname = std::string ([[cont name] cString]);
        std::string name = std::string(orname);
        name.append ("-#-#-");
        name.append ([[[cont entityType] name] cString]);

	/* creating or re-using the container scene node */
        Ogre::SceneNode *n;
	Ogre::Vector3 pos = Ogre::Vector3(x, 0, y);
        try {
		//container already exists, puting scene
		//node and position in the vectors
	        n = mSceneMgr->getSceneNode (orname);
		vectSceneNodes->push_back(n);
		PosDestino->push_back(pos);
		return n;
	}catch (Ogre::Exception ex){
		n = node->createChildSceneNode (orname);
        }
	//new container, so no animation, just put it on the scene
        n->setPosition(x, 0, y);

	/* creating or re-using the visual representation of the container */
        Ogre::Entity *e;
        try {
                e = mSceneMgr->getEntity(orname);
        }catch (Ogre::Exception ex){
                e = mSceneMgr->createEntity (orname,
                                Ogre::SceneManager::PT_CUBE);
        }
        e->setUserAny (Ogre::Any (name));
        e->setMaterialName ("VisuApp/Base");
        e->setQueryFlags(CONTAINER_MASK);

	/* creating or re-using the visual scene node of the container */
	std::string visualSceneNodeName = std::string (orname);
	visualSceneNodeName.append("visualRepresentation");
	Ogre::SceneNode *entn;
	try {
		entn = mSceneMgr->getSceneNode (visualSceneNodeName);
	}catch (Ogre::Exception ex){
		entn = n->createChildSceneNode(visualSceneNodeName);
		entn->attachObject (e);
		entn->setScale (.3,.01,.3);
		entn->setInheritScale (false);
	}

	/* creating or re-using the text scene node of the container */
	std::string textSceneNodeName = std::string (orname);
	textSceneNodeName.append("textRepresentation");
	Ogre::SceneNode *entnt;
	try{	
                entnt = mSceneMgr->getSceneNode (textSceneNodeName);
        }catch(Ogre::Exception ex){
                entnt = n->createChildSceneNode (textSceneNodeName);
                MovableText *text;
                NSString *textid;
                textid = [NSString stringWithFormat: @"%@-t", [cont name]];
                text = new MovableText ([textid cString], [textid cString]);
                text->setColor (Ogre::ColourValue::Blue);
                text->setCharacterHeight (15);
                entnt->setInheritScale (false);
                entnt->attachObject (text);
        }
	return n;
}

void DrawManager::applicationAnimatedGraphRecursiveDraw (id entity,
			Position *position,
			Ogre::SceneNode *node,
			std::vector<Ogre::SceneNode*> *vectSceneNodes,
			std::vector<Ogre::Vector3> *PosDestino)
{
	/* finding its position */
	int x = [position positionXForNode: [entity name]];
	int y = [position positionYForNode: [entity name]];
	
	this->getOneContainerPosition (entity, node, x, y, vectSceneNodes, PosDestino);

	/* recursive */
	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:entity]] objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [viewController enumeratorOfContainersTyped:et inContainer:entity];
			while ((sub = [en2 nextObject]) != nil) {
				this->applicationAnimatedGraphRecursiveDraw(
					(id)sub, position, node, vectSceneNodes,
					PosDestino);
			}
		}
	}
}

void DrawManager::applicationAnimatedGraphDraw (Position *position,
		float animationTime)
{
	id instance = [viewController rootInstance];

	std::vector<Ogre::SceneNode*> *vectSceneNodes;
	std::vector<Ogre::Vector3> *PosDestino;
	vectSceneNodes = new std::vector<Ogre::SceneNode*>;	
	PosDestino = new std::vector<Ogre::Vector3>;

	this->applicationAnimatedGraphRecursiveDraw (instance, position,
			containerPosition, vectSceneNodes, PosDestino);

 	if (vectSceneNodes->size() > 0) {
		this->moveSceneNodesToNewPositions (vectSceneNodes,
			PosDestino, animationTime);
	}

	vectSceneNodes->~vector();
	delete PosDestino;
}

