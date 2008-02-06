#include "YAxis.h"

YAxis::YAxis (double si, double sc, Origin *origin) :
	Axis::Axis (si, sc)
{
	sceneMgr = origin->getNode()->getCreator();
	node = origin->getNode()->createChildSceneNode ("YAxis");

	Ogre::ManualObject *line = sceneMgr->createManualObject ("YAxis");
	line->begin ("VisuApp/YAxis", Ogre::RenderOperation::OT_LINE_LIST);
	line->position (0, 0, 0);
	line->position (0, size, 0);
	line->end();
	line->setQueryFlags(AMBIENT_MASK);
	node->attachObject (line);

	int i;
	for (i = 0; i < size; i += 60){
		static int x = 0;
		char name[100];
		sprintf (name, "YAxisMark-%d", x);
		Ogre::ManualObject *mark;
		mark = sceneMgr->createManualObject (name);
		mark->begin ("VisuApp/YAxis", Ogre::RenderOperation::OT_LINE_LIST);
		mark->position (10, i, 0);
		mark->position (0, i, 0);
		mark->position (0, i, 10);
		mark->position (0, i, 0);
		mark->end();
		mark->setQueryFlags(AMBIENT_MASK);
		node->attachObject (mark);

		char nodeName[100], textId[100], textValue[100];
		sprintf (nodeName, "YAxisMark-%d-node", x);
		sprintf (textId, "YAxisMark-%d-textId", x++);
		sprintf (textValue, "%d", i);

		Ogre::SceneNode *textNode;
		textNode = node->createChildSceneNode (nodeName);

		Ogre::String markNameId = Ogre::String (textId);
		Ogre::String markName = Ogre::String (textValue);

		MovableText *text = new MovableText (markNameId, markName);
		text->setColor (Ogre::ColourValue::Blue);
		text->setCharacterHeight (15);
		text->setQueryFlags(AMBIENT_MASK);
		textNode->attachObject (text);
		textNode->setPosition (0, i, 0);
		textNode->setInheritScale (false);
	}
};
