#ifndef __FUSIONCONTAINER_H
#define __FUSIONCONTAINER_H
#include <Foundation/Foundation.h>
#include <General/PajeContainer.h>

@interface FusionContainer  : PajeContainer
{
	NSMutableDictionary *userEntities; //key = entityType
}
@end

#endif
