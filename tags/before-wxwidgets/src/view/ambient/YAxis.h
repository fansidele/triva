#ifndef __YAXIS_H
#define __YAXIS_H

#include <Ogre.h>
#include "view/ambient/Axis.h"
#include "view/ambient/Origin.h"

class YAxis : public Axis
{
private:
	Ogre::SceneNode *node;
	Ogre::SceneManager *sceneMgr;

public:
	YAxis (double si, double sc, Origin *origin);
	~YAxis () {};
};

#include "view/extras/MovableText.h"
#endif
