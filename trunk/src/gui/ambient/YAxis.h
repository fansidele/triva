#ifndef __YAXIS_H
#define __YAXIS_H

#include <Ogre.h>
#include "gui/ambient/Axis.h"
#include "gui/ambient/Origin.h"

class YAxis : public Axis
{
private:
	Ogre::SceneNode *node;
	Ogre::SceneManager *sceneMgr;

public:
	YAxis (double si, double sc, Origin *origin);
	~YAxis () {};
};

#include "gui/extras/MovableText.h"
#endif
