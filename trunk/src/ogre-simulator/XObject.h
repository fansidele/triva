#ifndef __XOBJECT_H
#define __XOBJECT_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "general/Macros.h"
#include "gui/draw/layout/Layout.h"

@class XState;
@class XLink;
@class XContainer;

@interface XObject  : NSObject
{
	XContainer *container;
	Ogre::SceneNode *node;
	NSString *start;
	NSString *end;	
	NSString *identifier;

	NSString *type; /* EntityType desse objeto */

	Layout *layout;
}
- (BOOL) identifierExists: (NSString *) ide;

- (BOOL) setContainer: (XContainer *) cont;
- (void) setNode: (Ogre::SceneNode *) snode; /* just to set root */
- (void) setStart: (NSString *) s;
- (void) setEnd: (NSString *) e;
- (void) setIdentifier: (NSString *) ide;
- (void) setPosition: (Ogre::Vector3) vector;
- (void) setLayout: (Layout *) lay;
- (void) updateLayout;
- (void) setType: (NSString *) t;

- (Ogre::Vector3) getPosition;
- (XContainer *) container;
- (Ogre::SceneNode *) node;
- (NSString *) start;
- (NSString *) end;
- (NSString *) identifier;
- (NSString *) type;
- (Layout *) layout;

@end

#include "XState.h"
#include "XLink.h"
#include "XContainer.h"

#endif
