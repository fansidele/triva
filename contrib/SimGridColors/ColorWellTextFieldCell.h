/* All Rights reserved */

#include <AppKit/AppKit.h>

@interface ColorWellTextFieldCell : NSTextFieldCell
{
  NSColorWell *colorWell;
  NSTextField *textField;
}
- (void) setWellColor: (BOOL) wc;
- (NSColor*)color;
- (void) setColor: (NSColor*)color;
@end
