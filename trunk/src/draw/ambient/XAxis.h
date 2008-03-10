#ifndef __XAXIS_H
#define __XAXIS_H

#include <Ogre.h>
#include "Axis.h"
#include "Origin.h"
#include "draw/QueryFlags.h"

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
