#ifndef __MARCO_H
#define __MARCO_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <gvc.h>
#include "MarcoWindow.h"

@interface Marco  : PajeFilter
{
}
- (void) dumpTraceInTextualFormat;
- (BOOL) checkForMarcoHierarchy;
- (NSArray *) findContainersAt: (id) instance;
- (NSArray *) findLinksAt: (id) instance;
@end

#endif
