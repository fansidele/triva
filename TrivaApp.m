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
