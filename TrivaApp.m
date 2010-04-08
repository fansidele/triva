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
#include "TrivaPajeComponent.h"
#include "TrivaCommand.h"


int main (int argc, const char **argv){
  //appkit init
	NSApplication *app = [NSApplication sharedApplication];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  TrivaPajeComponent *triva = [[TrivaPajeComponent alloc] init];

  //parsing args
  struct arguments arguments;
  arguments.treemap = 0;
  arguments.graph = 0;
  arguments.dot = 0;
  arguments.abort = 0;
  parse (argc, (char**)argv, &arguments);

  //configuring triva
  if (arguments.treemap) {
    [triva activateTreemap];
  }else if (arguments.graph){
    [triva activateGraph];
  }else if (arguments.dot) {
    [triva activateDot];
  }else{
    NSException *exception = [NSException exceptionWithName: @"TrivaException"
                   reason: @"No visualization option activated" userInfo: nil];
    [exception raise];
  }
  NSString *input = [NSString stringWithFormat: @"%s", arguments.input[0]];
  id reader = [triva componentWithName: @"FileReader"];
  [reader setInputFilename: input];
  NSLog (@"Tracefile (%@). Reading.... please wait\n", input);
  while ([triva hasMoreData]){
    [triva readNextChunk: nil];
  }
  NSLog (@"End of reading - %@ to %@.", [triva startTime], [triva endTime]);
  [triva setSelectionStartTime: [triva startTime] endTime: [triva endTime]];

  //run the application
  [app run];

  //that's it
	[pool release];
	return 0;
}
