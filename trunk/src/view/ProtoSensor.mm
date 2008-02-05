#include "view/ProtoSensor.h"

bool ProtoSensor::frameEnded (const Ogre::FrameEvent& evt) 
{
	return true; 
} 

bool ProtoSensor::frameStarted (const Ogre::FrameEvent& evt) 
{ 
	static float time = 0;

	time += evt.timeSinceLastFrame;
	if (time > .2){
		if ([viewController hasMoreData]) {
			[viewController read];
		}
//		time = 0;
	}
	return true; 
} 

ProtoSensor::~ProtoSensor ()
{
	[viewController release];
}

ProtoSensor::ProtoSensor (ProtoView *controller)
{
	viewController = controller;
	[viewController retain];
}
