#ifndef __GROUND_H
#define __GROUND_H

#include <Ogre.h>
#include "view/ambient/Origin.h"

#define SPACE_BETWEEN_LINES 50

class Ground 
{
private:
	double size;
	double scale;
	Ogre::SceneNode *node;
	Ogre::SceneManager *sceneMgr;

public:
	Ground (double si, double sc, Origin *origin);
	~Ground () {};
};

#endif
