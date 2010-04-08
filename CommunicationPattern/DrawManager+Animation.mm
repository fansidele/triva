#include "DrawManager.h"
#include "Position.h"
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
        n->setPosition(pos);
        vectSceneNodes->push_back(n);
        PosDestino->push_back(pos);

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

void DrawManager::applicationGraphDrawLines (Position *position)
{
	Ogre::SceneNode *glsn;
	try {
		glsn = mSceneMgr->getSceneNode ("GL-SN");
		glsn->detachAllObjects(); //this causes memory leak
		glsn->removeAllChildren(); //this may cause memory leak
	}catch (Ogre::Exception ex){
		glsn = mSceneMgr->getRootSceneNode(
					)->createChildSceneNode("GL-SN");
	}

	NSEnumerator *en = [[position allLinks] objectEnumerator];
	id oneLink;
	while ((oneLink = [en nextObject]) != nil){
		if ([oneLink count] < 2 || [oneLink count] > 2){
			continue;
		}
		NSString *head = [[oneLink allObjects] objectAtIndex: 0];
		NSString *tail = [[oneLink allObjects] objectAtIndex: 1];
		std::string headname = std::string ([head cString]);
		std::string tailname = std::string ([tail cString]);
        	Ogre::SceneNode *headnode;
        	try {
	        	headnode = mSceneMgr->getSceneNode (headname);
		}catch (Ogre::Exception ex){
			continue;
        	}
		Ogre::SceneNode *tailnode;
		try {
			tailnode = mSceneMgr->getSceneNode (tailname);
		}catch (Ogre::Exception ex){
			continue;
		}

		NSString *linkName = [NSString stringWithFormat: @"BL-%@-%@",
				head, tail];
		std::string linkname = std::string ([linkName cString]);
		std::string linknamear = linkname;
		linknamear.append("ar");

		Ogre::ManualObject *ste;
		try {
			ste = mSceneMgr->getManualObject(linkname);
		}catch (Ogre::Exception ex){
			ste = mSceneMgr->createManualObject(linkname);
		}

		//obtaining 3d positions
		Ogre::Vector3 op, dp;
#if OGRE_VERSION_MAJOR == 1 && OGRE_VERSION_MINOR == 6
		op = headnode->_getDerivedPosition();	
		dp = tailnode->_getDerivedPosition();
#else
		op = headnode->getWorldPosition();
		dp = tailnode->getWorldPosition();
#endif
		op.y = dp.y = 0;
		Ogre::Vector3 dif = (dp - op) * .10; //10% of difference
		dp = dp - dif;

		//drawing the line
		ste->clear ();
		ste->begin ("VisuApp/MPI_RECV",
			Ogre::RenderOperation::OT_LINE_STRIP);
		ste->position (op.x, 0, op.z);
		ste->position (dp.x, 0, dp.z);
		ste->end();


		//arrow
		Ogre::Entity *arrow;
		std::string x = linknamear;
		x.append("entity");
		try {
			arrow = mSceneMgr->getEntity (x);
		}catch(Ogre::Exception ex){
			arrow = mSceneMgr->createEntity(x,"cone.mesh");
			arrow->setMaterialName ("VisuApp/MPI_RECV");
		}
		//scene node for the arrow
		Ogre::SceneNode *arrowsn;
		try{
			arrowsn = mSceneMgr->getSceneNode (linknamear);
			if (!arrowsn->isInSceneGraph()){
				glsn->addChild (arrowsn);
			}
		}catch (Ogre::Exception ex){
			arrowsn = glsn->createChildSceneNode (linknamear);
		}
		try{
			arrowsn->attachObject (arrow);
		}catch(Ogre::Exception ex){
			//was already attached
		}
		arrowsn->setScale (5,5,5);
		arrowsn->setPosition (dp.x, 2, dp.z);

		arrowsn->resetOrientation();
		Ogre::Vector3 src = arrowsn->getOrientation() *
						Ogre::Vector3::UNIT_Y;
		Ogre::Quaternion quat = src.getRotationTo (dp-op);
		arrowsn->rotate (quat);

		try {
			glsn->attachObject (ste);
		}catch (Ogre::Exception ex){
			//already attached
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

	this->applicationGraphDrawLines (position);
	vectSceneNodes->~vector();
	delete PosDestino;
}


void DrawManager::fillVectorSceneNodes (Position *position,
                std::vector<Ogre::SceneNode*> *vectSceneNodes)
//return the vector with all the scene nodes
{ 
        id instance = [viewController rootInstance];

        std::vector<Ogre::Vector3> *PosDestino; //ignore this, just created to reuse former methods
	PosDestino = new std::vector<Ogre::Vector3>;

        this->applicationAnimatedGraphRecursiveDraw (instance, position,
                        containerPosition, vectSceneNodes, PosDestino);

        delete PosDestino;

}


float DrawManager::avarageDistance (std::vector<Ogre::SceneNode*> vectSceneNodes, Ogre::SceneNode *sceneNodePrinc)
{
	float varAvarageDistance, distancesAdds;
	distancesAdds = sceneNodePrinc->getPosition().distance(vectSceneNodes.at(0)->getPosition());

	for (int i = 1; i < vectSceneNodes.size(); i++){
		distancesAdds += sceneNodePrinc->getPosition().distance(vectSceneNodes.at(i)->getPosition());
	}	
	
	varAvarageDistance = distancesAdds / vectSceneNodes.size();
	return (varAvarageDistance);
}
//=====================================================================================================================================================
//=====================================================================================================================================================
std::vector<Ogre::Vector3> DrawManager::calcNewPositions (std::vector<Ogre::SceneNode*> vectSceneNodes, Ogre::SceneNode *sceneNodePrinc, float varFactorOfDistance, float rayOfAction)

{
	Ogre::Vector3 originalPos, NewCoordinate, distance, mainSceneNodePos;
	std::vector<Ogre::Vector3> vectDestPos;

	float avarageDist, incDist, distFromMainNode; 
	
	mainSceneNodePos = sceneNodePrinc->getPosition();

	avarageDist = avarageDistance(vectSceneNodes, sceneNodePrinc);

	incDist = avarageDist * varFactorOfDistance;
	incDist -= avarageDist;

	int i = 0;
	while (i < vectSceneNodes.size()){
		distFromMainNode = sceneNodePrinc->getPosition().distance(vectSceneNodes.at(i)->getPosition());

		if (distFromMainNode < rayOfAction) {
		originalPos = vectSceneNodes.at(i)->getPosition();
		distance = originalPos - mainSceneNodePos;
		distance.normalise();
		distance *= incDist; 
		NewCoordinate = distance + originalPos;
		vectDestPos.push_back(NewCoordinate);	

		}
		else {
			vectDestPos.push_back(vectSceneNodes.at(i)->getPosition());
		}

		i +=1;		
	}
	return(vectDestPos);	
}
