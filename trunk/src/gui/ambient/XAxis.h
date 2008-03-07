#ifndef __XAXIS_H
#define __XAXIS_H

#include <Ogre.h>
#include "gui/ambient/Axis.h"
#include "gui/ambient/Origin.h"
#include "gui/QueryFlags.h"

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
