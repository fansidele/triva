#ifndef __MARCO_H
#define __MARCO_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <graphviz/gvc.h>
#include "NUCAWindow.h"

@interface NUCA  : PajeFilter
{
}
- (void) dumpTraceInTextualFormat;
- (BOOL) checkForNUCAHierarchy;
- (NSArray *) findContainersAt: (id) instance;
- (NSArray *) findLinksAt: (id) instance;
@end

#endif
