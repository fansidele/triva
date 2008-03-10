#ifndef __ZAXIS_H
#define __ZAXIS_H

#include <Ogre.h>
#include "gui/ambient/Axis.h"
#include "gui/ambient/Origin.h"

class ZAxis : public Axis
{
private:
	Ogre::SceneNode *node;
	Ogre::SceneManager *sceneMgr;

public:
	ZAxis (double si, double sc, Origin *origin);
	~ZAxis () {};
};

#endif
