#ifndef __FUSIONCONTAINER_H
#define __FUSIONCONTAINER_H
#include <Foundation/Foundation.h>
#include <General/PajeContainer.h>
#include <General/ChunkArray.h>

@interface FusionContainer  : PajeContainer
{
//	NSMutableDictionary *userEntities; //key = entityType
	ChunkArray *mergedState;
}
@end

#endif
