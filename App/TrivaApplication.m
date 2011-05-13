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
#include "TrivaApplication.h"

@implementation TrivaApplication
+ (NSDictionary *) defaultOptions
{
  NSMutableDictionary *options = [NSMutableDictionary dictionary];

  //add components options
  Class cl;
  id dict;
  NSArray *ar = [NSArray arrayWithObjects: @"TimeInterval",
                                           @"GraphConfiguration", nil];
  NSEnumerator *en = [ar objectEnumerator];
  id className;
  while ((className = [en nextObject])){
    cl = [[TrivaApplication bundleWithName: className] principalClass];
    dict = [cl defaultOptions];
    [options addEntriesFromDictionary: dict];
  }

  //add triva options
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *file = [bundle pathForResource: @"Triva" ofType: @"plist"];
  [options addEntriesFromDictionary:
                 [NSDictionary dictionaryWithContentsOfFile: file]];
  return options;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
NS_DURING
  NSDictionary *defaultOptions = [TrivaApplication defaultOptions];
  NSMutableArray *arguments = [NSMutableArray arrayWithArray:
                              [[NSProcessInfo processInfo] arguments]];
  [arguments removeObjectAtIndex: 0];
  NSString *line = [arguments componentsJoinedByString:@" "];

  TrivaCommand *command = [[TrivaCommand alloc] initWithString: line
                                             andDefaultOptions: defaultOptions];

  if ([command state] == TrivaHelp){
    [TrivaCommand printOptions: defaultOptions];
    [NSApp terminate: self];
  }else if ([command state] == TrivaCommandConfigured){
    [TrivaController controllerWithConfiguration: [command configuration]];
  }else{
    [NSApp terminate: self];
  }
  [command release];
 NS_HANDLER
   printf ("\n%s: %s\n\n", [[localException name] cString],
                     [[localException reason] cString]);
   exit(1);
 NS_ENDHANDLER
}
@end
