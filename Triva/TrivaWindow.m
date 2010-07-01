/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "TrivaWindow.h"

@implementation TrivaWindow
- (void) initializeWithDelegate: (id) delegate
{
  NSString *name = [NSString stringWithFormat: @"%@", [delegate class]];
  NSWindow *window = self;
  [window setTitle: name];
  [window setDelegate: delegate];
  [[window windowController] setShouldCascadeWindows:NO];
  [window setFrameAutosaveName: name];
}
@end
