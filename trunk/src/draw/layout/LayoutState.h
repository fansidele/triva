#ifndef __LAYOUTSTATE_H
#define __LAYOUTSTATE_H
#include <Foundation/Foundation.h>
#include <Ogre.h>
#include "gui/draw/layout/Layout.h"

@interface LayoutState : Layout
{
	double start;
	double end;
}
- (void) setStart: (double) s;
- (void) setEnd: (double) e;
@end

#endif
