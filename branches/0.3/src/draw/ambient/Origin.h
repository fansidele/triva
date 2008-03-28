#ifndef __ORIGIN_H
#define __ORIGIN_H

#include <Ogre.h>

class XAxis;
class YAxis;
class ZAxis;
class Ground;

class Origin
{
protected:
	Ogre::SceneNode *node;
	Ogre::SceneManager *sceneMgr;
	
	XAxis *xAxis;
	YAxis *yAxis;
	ZAxis *zAxis;
	Ground *ground;

public:
	Origin (Ogre::SceneNode *parent);
	Origin () {};
	~Origin () {};

	void setXAxis (XAxis *axis) { xAxis = axis; };
	void setYAxis (YAxis *axis) { yAxis = axis; };
	void setZAxis (ZAxis *axis) { zAxis = axis; };
	void setGround (Ground *g)  { ground = g; };
	Ogre::SceneNode *getNode () { return node; };
};

#include "XAxis.h"
#include "YAxis.h"
#include "ZAxis.h"
#include "Ground.h"
#endif