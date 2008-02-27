#ifndef __XLINK_H
#define __XLINK_H
#include <Foundation/Foundation.h>
#include "XObject.h"

@class XContainer;

@interface XLink  : XObject
{
	BOOL finalized;
	XContainer *source;
	XContainer *dest; 
}

- (BOOL) finalized;
- (XContainer *) sourceContainer;
- (XContainer *) destContainer;

- (void) setFinalized: (BOOL) v;
- (void) setSourceContainer: (XContainer *) c;
- (void) setDestContainer: (XContainer *) c;
@end

#endif
