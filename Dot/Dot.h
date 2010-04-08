#ifndef __MARCO_H
#define __MARCO_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <graphviz/gvc.h>

@interface Dot  : PajeFilter
{
}
- (NSString *) dotTypeHierarchy;
- (NSString *) dotTypeHierarchy: (id) type;
- (void) dumpTraceInTextualFormat;
@end

#endif