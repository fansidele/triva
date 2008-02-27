#ifndef __XSTATE_H
#define __XSTATE_H
#include <Foundation/Foundation.h>
#include "XObject.h"

@interface XState  : XObject
{
	BOOL finalized;
}
- (BOOL) finalized;
- (void) setFinalized: (BOOL) v;
@end

#endif
