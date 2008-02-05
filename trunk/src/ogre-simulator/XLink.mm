#include "XLink.h"

@implementation XLink
- (id) init
{
	self = [super init];
	finalized = NO;
	start = nil;
	end = nil;
	return self;
}

- (BOOL) finalized
{
	return finalized;
}

- (void) setFinalized: (BOOL) v
{
	finalized = v;
}

- (void) setLayout: (Layout *) lay
{
	[super setLayout: lay];
	//NSLog (@"%@ %@", identifier, type);
	[layout createWithIdentifier: identifier andMaterial: type];
	[layout attachTo: node];
	if (finalized == YES){
		[self updateLayout];
	}
}	

- (void) updateLayout
{
//	NSLog (@"%s start=%@ end=%@", __FUNCTION__, start, end);
	[layout setStart: [start doubleValue]];
	if (end != nil){
		[layout setEnd: [end doubleValue]];
	}else{
		[layout setEnd: [start doubleValue]];
	}
	/* source and destinations positions */

	if (finalized){
		Ogre::Vector3 posOrigin = [source getPosition];
		Ogre::Vector3 posDest = [dest getPosition];
		Ogre::Vector3 dif = posDest-posOrigin;
		[layout setSourceX: 0 andZ: 0];
		[layout setDestX: dif.x andZ: dif.z];
		[layout redraw];
	}
}

- (void) setSourceContainer: (XContainer *) c
{
	source = c;
	[source retain];
}

- (void) setDestContainer: (XContainer *) c
{
	dest = c;
	[dest retain];
}

- (void) dealloc
{
	[source release];
	[dest release];
	[super dealloc];
}

- (XContainer *) sourceContainer
{
	return source;
}

- (XContainer *) destContainer
{
	return dest;
}

@end
