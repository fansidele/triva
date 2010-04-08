#ifndef __MAFilter_H
#define __MAFilter_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "MALayout.h"

@interface MemoryAccess  : PajeFilter
{
	MALayout *current;
}
- (MALayout *) layoutWithWidth: (int) width andHeight: (int) height;
@end

#endif
