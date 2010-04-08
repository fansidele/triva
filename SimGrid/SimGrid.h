#ifndef __SIMGRID_H
#define __SIMGRID_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <gvc.h>
#include "SimGridWindow.h"

@interface SimGrid  : PajeFilter
{
}
- (void) dumpTraceInTextualFormat;
- (BOOL) checkForSimGridHierarchy: (id) type level: (int) level;
- (NSArray *) findHostsAt: (id) instance;
- (NSArray *) findRoutesAt: (id) instance;
@end

#endif
