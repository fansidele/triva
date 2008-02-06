#ifndef __XAXIS_H
#define __XAXIS_H

#include <Ogre.h>
#include "view/ambient/Axis.h"
#include "view/ambient/Origin.h"
#include "view/QueryFlags.h"

class XAxis : public Axis
{
private:
	Ogre::SceneNode *node;
	Ogre::SceneManager *sceneMgr;

public:
	XAxis (double si, double sc, Origin *origin);
	~XAxis () {};
};

#endif
