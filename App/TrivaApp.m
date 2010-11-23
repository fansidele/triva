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
#include "TrivaController.h"
#include "TrivaCommand.h"

int main (int argc, const char **argv){
  //appkit init
  NSApplication *app = [NSApplication sharedApplication];
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  //parsing command line
  TrivaController *triva = [[TrivaController alloc] init];
  NSDictionary *allOptions = [triva defaultOptions];
  TrivaCommand *command;
NS_DURING
  command = [[TrivaCommand alloc] initWithArguments: argv
                                            andSize: argc
                                  andDefaultOptions: allOptions];
NS_HANDLER
  printf ("%s: %s\n\n", [[localException name] cString],
                    [[localException reason] cString]);
  exit(1);
NS_ENDHANDLER
  if ([command state] == TrivaHelp){
    [TrivaCommand printOptions: allOptions];
  }else if ([command state] == TrivaCommandConfigured){
    printf ("%s", [[[command configuration] description] cString]);

    //initializing controller with options and input file names
    triva = [TrivaController controllerWithConfiguration:
                                                       [command configuration]];
    //run the application
    [app run];
  }

  //that's it
  [pool release];
  return 0;
}
