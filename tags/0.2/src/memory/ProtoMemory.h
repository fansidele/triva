#ifndef __PROTOMEMORY_H
#define __PROTOMEMORY_H
#include <Foundation/Foundation.h>
#include "general/ProtoComponent.h"

@interface ProtoMemory  : ProtoComponent
{
	NSMutableArray *objects;
	int readIndex;
}
@end

#endif
