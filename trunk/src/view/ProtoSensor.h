#ifndef __PROTO_SENSOR_H
#define __PROTO_SENSOR_H

#include <Ogre.h>
#include <OIS.h>

@class ProtoView;

class ProtoSensor : public Ogre::FrameListener
{
private:
	ProtoView *viewController;

public: 
	ProtoSensor (ProtoView *controller);
	~ProtoSensor ();

protected:
	bool frameStarted (const Ogre::FrameEvent& evt);
	bool frameEnded (const Ogre::FrameEvent& evt);
};

#include "view/ProtoView.h"
#endif
