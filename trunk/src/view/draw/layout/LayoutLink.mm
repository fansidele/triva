#include "LayoutLink.h"

//#define SPHERE

@implementation LayoutLink
- (id) init
{
	self = [super init];
	start = end = 0;
	return self;
}
- (void) createWithIdentifier: (NSString *) ide andMaterial: (NSString *) mat
{
	Ogre::Root *mRoot = Ogre::Root::getSingletonPtr();
	Ogre::SceneManager * mSceneMgr = mRoot->getSceneManager("VisuSceneManager");
	
	std::string materialName;
	materialName.append("VisuApp/MPI_SEND");
//	materialName.append([mat cString]);

/*
        line = mSceneMgr->createManualObject([ide cString]);
        line->begin (materialName, Ogre::RenderOperation::OT_LINE_LIST);
        line->position (0,0,0);
        line->position (0,0,0);
        line->end();
*/

	line = new DynamicLines(Ogre::RenderOperation::OT_LINE_LIST);
	line->setMaterial (materialName);
	line->addPoint (Ogre::Vector3 (0,0,0));
	line->addPoint (Ogre::Vector3 (0,0,0));
	line->update();
	line->setQueryFlags(LINK_MASK);

	std::string x, y;
	x = [ide cString];
	x.append ("Start");
	y = [ide cString];
	y.append ("End");

        startBall = mSceneMgr->createEntity (x, Ogre::SceneManager::PT_SPHERE);
        startBall->setMaterialName ("VisuApp/Green");

        endBall = mSceneMgr->createEntity (y, Ogre::SceneManager::PT_SPHERE);
        endBall->setMaterialName ("VisuApp/Red");


/*	
	entity = mSceneMgr->createEntity ([ide cString], Ogre::SceneManager::PT_CUBE);
	entity->setMaterialName (materialName);
	
	text = new MovableText ([ide cString], [ide cString]);
	text->setColor (Ogre::ColourValue::Blue);
	text->setCharacterHeight (15);
*/
}

- (void) attachTo: (Ogre::SceneNode *) node
{
	[super attachTo: node];
	sceneNode = node->createChildSceneNode ();
	sceneNode->attachObject (line);


#ifdef SPHERE
	startBallSceneNode = sceneNode->createChildSceneNode();
	startBallSceneNode->attachObject (startBall);
	startBallSceneNode->setPosition (0,start,0);
	startBallSceneNode->setScale (0.1,0.1,0.1);
	startBallSceneNode->setInheritScale (false);

	endBallSceneNode = sceneNode->createChildSceneNode();
	endBallSceneNode->attachObject (endBall);
	endBallSceneNode->setPosition (destX,end,destZ);
	endBallSceneNode->setScale (0.1,0.1,0.1);
	endBallSceneNode->setInheritScale (false);
#endif
	

//	sceneNode->setScale (0,0,0);
//	sceneNode->setPosition (0,0,0);
}

- (void) setStart: (double) s
{
	start = s;
}

- (void) setEnd: (double) e
{
	end = e;
}

- (void) redraw
{
//	NSLog (@"%s %f,%f,%f -> %f,%f,%f", __FUNCTION__, sourceX,start,sourceZ, destX, end, destZ);
	if (start == 0 && end == 0){
		NSLog (@"warning: start = 0 end = 0 at %@", self);
//		sceneNode->setPosition (0,0,0);
//		sceneNode->setScale (0,0,0);
	}else{
		line->setPoint (0,Ogre::Vector3(0,start,0));
		line->setPoint (1,Ogre::Vector3(destX,end,destZ));
		line->update();

#ifdef SPHERE
		startBallSceneNode->setPosition (0,start,0);
		endBallSceneNode->setPosition (destX,end,destZ);
#endif


/*
		line->beginUpdate (0);
		line->position (0, start, 0);
		line->position (destX, end, destZ);
		line->end();
*/
	}
}

- (void) setSourceX: (double) x andZ: (double) z
{
	sourceX = x;
	sourceZ = z;
}

- (void) setDestX: (double) x andZ: (double) z
{
	destX = x;
	destZ = z;
}

@end
