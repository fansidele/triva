/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "TrivaWindow.h"

@implementation TrivaWindow
/* remember window position */
- (void) restoreWindowPosition
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  //window position
  NSPoint point;
  NSString *tx = [NSString stringWithFormat: @"%@OriginX", [self title]];
  NSString *ty = [NSString stringWithFormat: @"%@OriginY", [self title]];

  //check if it exists
  if ([defaults objectForKey: tx] && [defaults objectForKey: ty]){
     point.x = [[defaults objectForKey: tx] doubleValue];
     point.y = [[defaults objectForKey: ty] doubleValue];
     [self setFrameOrigin: point];
  }else{
     [self center];
  }
}

- (void) saveWindowPosition
{
  NSPoint point = [self frame].origin;
  NSString *tx = [NSString stringWithFormat: @"%@OriginX", [self title]];
  NSString *ty = [NSString stringWithFormat: @"%@OriginY", [self title]];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject: [NSString stringWithFormat: @"%f", point.x] forKey: tx];
  [defaults setObject: [NSString stringWithFormat: @"%f", point.y] forKey: ty];
  [defaults synchronize];
}
@end
