#ifndef __LAYOUTCONTAINER_H
#define __LAYOUTCONTAINER_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "draw/layout/Layout.h"

@interface LayoutContainer : Layout
{
	NSMutableArray *subcontainers;
	NSMutableArray *states;
}
- (void) addSubContainer: (LayoutContainer *) lc;
- (void) addState: (LayoutState *) ls;
@end

#endif
