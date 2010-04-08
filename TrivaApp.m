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

int main (int argc, const char **argv){
	NSApplication *app = [NSApplication sharedApplication];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (argc > 1){
		NSString *tfile = [NSString stringWithFormat: @"%s", argv[1]];
		TrivaPajeComponent *tPaje = [[TrivaPajeComponent alloc] init];
		[tPaje createComponentGraph]; /*must be called after param*/
		id reader = [tPaje componentWithName: @"FileReader"];
		[reader setInputFilename: tfile];
		[tPaje setReaderWithName: @"FileReader"];
		NSLog (@"Tracefile (%@). Reading.... please wait\n", tfile);
		while ([tPaje hasMoreData]){
			[tPaje readNextChunk: nil];
		}
		NSLog (@"End of reading - %@ to %@.",
			[tPaje startTime], [tPaje endTime]);
		[tPaje setSelectionStartTime: [tPaje startTime]
			endTime: [tPaje endTime]];
		[app run];
	}else{
		NSLog (@"Please, provide a .trace file");
		exit(1);
	}
	[pool release];
	return 0;
}
