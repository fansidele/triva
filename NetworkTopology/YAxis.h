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
	std::string unitName;
	std::string unitAbbreviation;
	double timeUnitDivisor;
	double pointsPerSecond;
	void activate (std::string scale, double increment);

public:
	YAxis (double si, double sc, Origin *origin);
	~YAxis () {};
	void newPointsPerSecond (double pps);
};

#include "MovableText.h"
#endif
