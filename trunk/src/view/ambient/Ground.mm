#include "Ground.h"

Ground::Ground (double si, double sc, Origin *origin) 
{
	int i;
	Ogre::SceneNode *groundNode;

	size = si;
	scale = sc;
	sceneMgr = origin->getNode()->getCreator();
	node = origin->getNode()->createChildSceneNode ("Ground");

	Ogre::ManualObject *plane;
	plane = sceneMgr->createManualObject ("Ground");
	plane->begin ("VisuApp/Ground");
	plane->position (-5, 0, -5);
	plane->position (5, 0, -5);
	plane->position (-5, 0, 5);
	plane->position (5, 0, 5);
	plane->triangle (2, 1, 0);
	plane->triangle (1, 2, 3);
	plane->end();

	si = si/4;

	groundNode = node->createChildSceneNode ("GroundNode");
	groundNode->attachObject (plane);
	groundNode->setScale (si, 0, si);




	Ogre::ManualObject *line;
	for (i = -si/2; i < si/2; i += SPACE_BETWEEN_LINES){
		static int x = 0;
		char name[100];
		sprintf (name, "GroundXLine-%d", x++);
		line = sceneMgr->createManualObject (name);
		line->begin("VisuApp/GroundLine", Ogre::RenderOperation::OT_LINE_STRIP);
		line->position (i, 0, -si/2);
		line->position (i, 0, si/2);	
		line->end();
		node->attachObject (line);
	}

	for (i = -si/2; i < si/2; i+= SPACE_BETWEEN_LINES){
		static int x = 0;
		char name[100];
		sprintf (name, "GroundZLine-%d", x++);
		line = sceneMgr->createManualObject (name);
		line->begin("VisuApp/GroundLine", Ogre::RenderOperation::OT_LINE_STRIP);
		line->position (-si/2, 0, i);
		line->position (si/2, 0, i);	
		line->end();
		node->attachObject (line);

	}


	std::cout << "###" << std::endl;

/*
	Ogre::Plane plane (Ogre::Vector3::UNIT_Y, 0);
	Ogre::MeshManager::getSingletonPtr()->createPlane(
                "gp.mesh",
                "Ground",
                plane,
                size,
                size,20,20,true,1,5,5,
                Ogre::Vector3::UNIT_Z);

        Ogre::Entity *yplane = sceneMgr->createEntity("Ground", "gp.mesh");
        yplane->setMaterialName ("VisuApp/Ground");
*/
        node->setPosition(si/2-100,0,si/2-100);
	
};
