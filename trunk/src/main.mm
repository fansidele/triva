#include <Foundation/Foundation.h>
#include "general/ProtoComponent.h"
#include "core/ProtoController.h"

int main(int argc, const char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ProtoController *controller = [[ProtoController alloc] initWithArgc: (int) argc andArgv: (char **) argv];
	if (controller != nil){
		[controller start];
		[controller release];
	}
	[pool release];
	return 0;
}
