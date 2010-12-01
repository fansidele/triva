/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GraphConfiguration.h"

@implementation GraphConfiguration (Interface)
- (void) initInterface
{
  [confView setDelegate: self];
  [window initializeWithDelegate: self];
}

- (void) refreshInterfaceWithConfiguration: (NSString *) gc
                      withTitle: (NSString *) gct
{
  //use configuration dictionary
  //use graphConfigurationFilename string

  [title setStringValue: gct];
  [confView setString: gc];
  [self textDidChange: self];
}

- (void) apply: (id)sender
{
  if ([ok state] == NSOnState){
    NSString *str;
    str = [NSString stringWithString:[[confView textStorage] string]];
    [self setGraphConfiguration: str withTitle: [title stringValue]];
    [self apply];
  }
}

- (void) updateTitle: (id)sender
{
  if ([ok state] == NSOnState){
    NSString *str;
    str = [NSString stringWithString:[[confView textStorage] string]];
    [self setGraphConfiguration: str withTitle: [title stringValue]];
  }
}

- (void) textDidChange: (id) sender
{
  NSString *str = nil;
  NSDictionary *dict = nil;
  NS_DURING
    str = [NSString stringWithString:[[confView textStorage] string]];
    dict = [str propertyList];
    if (dict){
      [ok setState: NSOnState];
    }
  NS_HANDLER
    [ok setState: NSOffState];
    NSLog (@"%@", localException);
  NS_ENDHANDLER
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}
@end
