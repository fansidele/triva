#ifndef __TRIVAFUSION_H
#define __TRIVAFUSION_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>

@interface TrivaFusion  : PajeFilter
{
	NSSet *containers;
}
- (void) mergeSelectedContainers;
@end

#endif
