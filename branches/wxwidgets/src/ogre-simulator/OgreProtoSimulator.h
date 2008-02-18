#ifndef __OGREPROTOSIMULATOR_H
#define __OGREPROTOSIMULATOR_H
#include <Foundation/Foundation.h>
#include <Paje/Paje.h>
#include "general/ProtoComponent.h"
#include "ogre-simulator/XObject.h"

@interface OgreProtoSimulator  : ProtoComponent
{
	XContainer *root;

	NSString *currentTime;
	NSString *startTime;
	NSString *endTime;

	PajeHierarchy *hierarchy;

	NSMutableDictionary *links;
	NSMutableDictionary *newLinks;
}
- (void) updateTimeAtUnfinishedObjects;
- (void) setCurrentTime: (NSString *) time;
@end

@interface OgreProtoSimulator (Events)
- (void) pajeCreateContainer: (PajeCreateContainer *) pcc;
- (void) pajeDestroyContainer: (PajeDestroyContainer *) pcc;
- (void) pajePushState: (PajePushState *) pps;
- (void) pajePopState: (PajePopState *) pps;
- (void) pajeSetState: (PajeSetState *) pps;
- (void) pajeStartLink: (PajeStartLink *) p;
- (void) pajeEndLink: (PajeEndLink *) p;
@end

#endif
