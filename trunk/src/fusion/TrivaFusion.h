#ifndef __TRIVAFUSION_H
#define __TRIVAFUSION_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "fusion/FusionContainer.h"

@interface TrivaFusion  : PajeFilter
{
	NSSet *containers;

	PajeEntity *stateType;
	FusionContainer *mergedContainer;
}
- (void) mergeSelectedContainers;
@end

#endif
