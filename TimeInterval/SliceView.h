/* All Rights reserved */
#ifndef __SLICE_VIEW_H
#define __SLICE_VIEW_H

#include <AppKit/AppKit.h>

@interface SliceView : NSView
{
  id filter;
}
- (void) setFilter: (id) f;
@end

#endif
