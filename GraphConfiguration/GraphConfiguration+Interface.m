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
  configurations = [[NSMutableDictionary alloc] init];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  id exist = [defaults objectForKey: @"GraphConfigurationItems"];
  if (exist){
    [configurations addEntriesFromDictionary: exist];
  }

  // gui configuration
  NSString *lastSelected;
  lastSelected = [defaults objectForKey: @"GraphConfigurationSelected"];
  if (lastSelected){
    [self refreshPopupAndSelect: lastSelected];
  }
  [confView setDelegate: self];
  [window initializeWithDelegate: self];
}

- (void) updateDefaults
{
  NSUserDefaults *defaults;
  defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject: configurations
         forKey: @"GraphConfigurationItems"];

  NSString *selected = [popup titleOfSelectedItem];
  if (selected){
    [defaults setObject: selected
         forKey: @"GraphConfigurationSelected"];
  }
  [defaults synchronize];
}

- (void) refreshPopupAndSelect: (NSString*)toselect
{
  [popup removeAllItems];
  [popup addItemsWithTitles: [configurations allKeys]];
  int select = 0;
  if ([configurations objectForKey: toselect]){
    select = [popup indexOfItemWithTitle: toselect];
  }
  [popup selectItemAtIndex: select];
  [self change: self];
}

- (void) apply: (id)sender
{
  NSString *current = [popup titleOfSelectedItem];
  NSDictionary *dict = [[configurations objectForKey: current]
          propertyList];

  if ([ok state] == NSOnState){
    NS_DURING
    [self setConfiguration: dict];
    NS_HANDLER
      NSLog (@"%@", localException);
    NS_ENDHANDLER
  }
}

- (void) newWithTitle: (NSString*)t andConf: (NSString*) c
{
  [popup addItemWithTitle: t];
  [popup selectItemWithTitle: t];
  [title setStringValue: t];
  [confView setString: c];
  [ok setState: NSOnState];
  [configurations setObject: c
     forKey: t];
  [self updateDefaults];
}

- (void) new: (id)sender
{
  static int counter = 0;
  NSString *nTitle=[NSString stringWithFormat:@"*(unnamed-%d)",counter++];
  while ([configurations objectForKey: nTitle]){
    nTitle = [NSString stringWithFormat:@"*(unnamed-%d)",counter++];
  }
  NSString *basic = @"{\n\
  node = ();\n\
  edge = ();\n\
\n\
  graphviz-algorithm = neato;\n\
}";
  [self newWithTitle: nTitle andConf: basic];
}

- (void) change: (id)sender
{
  NSString *selected = [popup titleOfSelectedItem];
  NSString *str = [configurations objectForKey: selected];
  [title setStringValue: selected];
  [confView setString: str];
  [ok setState: NSOnState];
  [self updateDefaults];
}

- (void) textDidChange: (id) sender
{
  NS_DURING
    NSString *str = [NSString stringWithString:
          [[confView textStorage] string]];
    id dict = [str propertyList];
    if (dict){
      [configurations setObject: str
           forKey: [popup titleOfSelectedItem]];
      [ok setState: NSOnState];
      [self updateDefaults];
    }
  NS_HANDLER
    [ok setState: NSOffState];
    NSLog (@"%@", localException);
  NS_ENDHANDLER
}

- (void) updateTitle: (id) sender
{
  if (![title stringValue]){
    return;
  }

  NSString *current = [popup titleOfSelectedItem];
  NSDictionary *dict = [configurations objectForKey: current];
  [dict retain];
  [configurations removeObjectForKey: current];
  [configurations setObject: dict forKey: [title stringValue]];
  [dict release];

  [self refreshPopupAndSelect: [title stringValue]];
  [self updateDefaults];
}

- (void) del: (id) sender
{
  [configurations removeObjectForKey: [popup titleOfSelectedItem]];
  [self refreshPopupAndSelect: nil];
  [self updateDefaults];
}

- (void) copy: (id) sender
{
  NSString *current = [popup titleOfSelectedItem];
  NSDictionary *dict = [configurations objectForKey: current];

  NSString *new = [NSString stringWithFormat: @"%@-copy", current];
  [self newWithTitle: new andConf: [dict description]];
}

- (void)windowDidMove:(NSNotification *)win
{
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}
@end
