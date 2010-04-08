#include "YAxis.h"

YAxis::YAxis (double si, double sc, Origin *origin) :
	Axis::Axis (si, sc)
{
	std::cout << __FUNCTION__ << std::endl;
	sceneMgr = origin->getNode()->getCreator();
	node = origin->getNode()->createChildSceneNode ("YAxis");

	Ogre::ManualObject *line = sceneMgr->createManualObject ("YAxis");
	line->begin ("VisuApp/YAxis", Ogre::RenderOperation::OT_LINE_LIST);
	line->position (0, 0, 0);
	line->position (0, size, 0);
	line->end();
	line->setQueryFlags(AMBIENT_MASK);
//	node->attachObject (line);
};

void YAxis::newPointsPerSecond (double pps)
{
	pointsPerSecond = pps;
	if (pps > 300000000) { //nano
		unitName = std::string ("nanoseconds");
		unitAbbreviation = std::string ("ns");
		timeUnitDivisor = 1000000000;
		this->activate (std::string ("ns"), pps);
	}else if (pps > 300000) { //micro
		unitName = std::string ("microseconds");
		unitAbbreviation = std::string ("\xb5s");
		timeUnitDivisor = 1000000;
		this->activate (std::string ("Ms"), pps);
	}else if (pps > 300) { //milli
		unitName = std::string ("milliseconds");
		unitAbbreviation = std::string ("ms");
		timeUnitDivisor = 1000;
		this->activate (std::string ("ms"), pps);
	}else if (pps > 0.1) { //seconds
		unitName = std::string ("seconds");
		unitAbbreviation = std::string ("s");
		timeUnitDivisor = 1;
		this->activate (std::string ("s"), pps);
	}else if (pps > .001) { //hours
		unitName = std::string ("hours");
		unitAbbreviation = std::string ("h");
		timeUnitDivisor = 1.0/3600.0;
		this->activate (std::string ("h"), pps);
	}else { //days
		unitName = std::string ("days");
		unitAbbreviation = std::string ("d");
		timeUnitDivisor = 1.0/3600.0/24.0;
		this->activate (std::string ("d"), pps);
	}
}

void YAxis::activate (std::string scale, double increment)
{
	Ogre::SceneNode *n = sceneMgr->getSceneNode ("YAxis");
	n->removeAndDestroyAllChildren();

	char nodename[100];
	snprintf (nodename, 100, "scale-%f", increment);
	Ogre::SceneNode *nn = n->createChildSceneNode (std::string (nodename));
	double i;
	for (i = 0; i < size; i+= 100){
		char nodeName[100], textId[100], textValue[100];
		sprintf (nodeName, "YAxisMark-%f-node", i);
		sprintf (textId, "YAxisMark-%f-textId", i);
		sprintf (textValue, "%.3f%s",i/increment,scale.c_str());
		Ogre::SceneNode *textNode;

		textNode = nn->createChildSceneNode (nodeName);
		Ogre::String markNameId = Ogre::String (textId);
		Ogre::String markName = Ogre::String (textValue);

		MovableText *text;
		text = new MovableText (markNameId, markName);
		text->setColor (Ogre::ColourValue::Blue);
		text->setCharacterHeight (15);
		text->setQueryFlags(AMBIENT_MASK);
//		textNode->attachObject (text);
		textNode->setPosition (0, i, 0);
		textNode->setInheritScale (false);
	}
}
