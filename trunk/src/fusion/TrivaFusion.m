#include "TrivaFusion.h"

@implementation TrivaFusion
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	return self;
}

- (void)setSelectedContainers:(NSSet *)cont
{
	NSLog (@"%@ containers=%@", self, containers);
	if (containers != nil){
		[containers release];
	}
	containers = cont;
	[containers retain];
	[super setSelectedContainers: cont];
}

- (void) mergeSelectedContainers
{
	NSLog (@"%@ %s containers=%@", self, __FUNCTION__, containers);
}
@end
