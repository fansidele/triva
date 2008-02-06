#include "ZAxis.h"

ZAxis::ZAxis (double si, double sc, Origin *origin) :
	Axis::Axis (si, sc)
{
	sceneMgr = origin->getNode()->getCreator();
	node = origin->getNode()->createChildSceneNode ("ZAxis");

	Ogre::ManualObject *line = sceneMgr->createManualObject ("ZAxis");
	line->begin ("VisuApp/ZAxis", Ogre::RenderOperation::OT_LINE_LIST);
	line->position (0, 0, 0);
	line->position (0, 0, size);
	line->end();
	line->setQueryFlags (AMBIENT_MASK);
	node->attachObject (line);
};
