#include "TrivaResourcesGraph.h"

@implementation TrivaResourcesGraph
- (id) initWithFile: (NSString *) f
{
	if (f == nil){
		return nil;
	}

	FILE *fo = fopen ([f cString], "r");
	if (fo == NULL){
		return nil;
	}

	self = [super init];

	file = f;
	[file retain];

	gvc = gvContext();
	g = agread (fo);

	fclose (fo);
	
	return self;
}

- (void) dealloc
{
	[file release];
	[algorithm release];
}

- (void) setAlgorithm: (NSString *) algo
{
	if (algorithm != nil){
		[algorithm release];
	}
	algorithm = algo;
	[algorithm retain];
}
@end
