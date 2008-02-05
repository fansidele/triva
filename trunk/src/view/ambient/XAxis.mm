#include "XAxis.h"

XAxis::XAxis (double si, double sc, Origin *origin) :
	Axis::Axis (si, sc)
{
	sceneMgr = origin->getNode()->getCreator();
	node = origin->getNode()->createChildSceneNode ("XAxis");

	Ogre::ManualObject *line = sceneMgr->createManualObject ("XAxis");
	line->begin ("VisuApp/XAxis", Ogre::RenderOperation::OT_LINE_LIST);
	line->position (0, 0, 0);
	line->position (size, 0, 0);
	line->end();
	node->attachObject (line);
};
