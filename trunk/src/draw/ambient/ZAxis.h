#ifndef __ZAXIS_H
#define __ZAXIS_H

#include <Ogre.h>
#include "Axis.h"
#include "Origin.h"

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
