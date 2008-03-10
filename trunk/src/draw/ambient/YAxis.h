#ifndef __YAXIS_H
#define __YAXIS_H

#include <Ogre.h>
#include "Axis.h"
#include "Origin.h"

class YAxis : public Axis
{
private:
	Ogre::SceneNode *node;
	Ogre::SceneManager *sceneMgr;

public:
	YAxis (double si, double sc, Origin *origin);
	~YAxis () {};
};

#include "draw/extras/MovableText.h"
#endif
