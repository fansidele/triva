#include "XObject.h"

@implementation XObject
- (id) init
{
	self = [super init];
	start = nil;
	end = nil;
	identifier = nil;
	node = NULL;
	container = nil;
	layout = nil;
	return self;
}

- (BOOL) setContainer: (XContainer *) cont
{

	if (identifier == nil){
		NSString *str;
		str = [NSString stringWithFormat: @"XObject (%@) does not have a name while trying to obtain its Ogre::SceneNode", self];
	        [[NSException exceptionWithName: @"SimulatorException"
                        reason: str userInfo: nil] raise];
		return NO;
	}

	container = cont;
	[container retain];

	/* creating node */
	Ogre::SceneNode *containerNode;
	containerNode = [container node];

	if (containerNode == NULL){
		NSString *str;
		str = [NSString stringWithFormat: @"At (%@), our container named %@ has a NULL containerNode (%@)", self, [container identifier], containerNode];
	        [[NSException exceptionWithName: @"SimulatorException"
                        reason: str userInfo: nil] raise];

	}
	std::string str = [identifier cString];
	node = containerNode->createChildSceneNode (str);
	return YES;
}

- (void) setNode: (Ogre::SceneNode *) snode
{
	node = snode;
}

- (void) setStart: (NSString *) s
{
	if (start != nil){
		[start release];
	}
	start = s;
	[start retain];
}

- (void) setEnd: (NSString *) e
{
	if (end != nil){
		[end release];
	}
	end = e;
	[end retain];
}

- (void) setIdentifier: (NSString *) ide
{
	if (identifier != nil){
		[identifier release];
	}
	identifier = ide;
	[identifier retain];
}

- (void) setType: (NSString *) t
{
	type = t;
	[type retain];
}

- (XContainer *) container
{
	return container;
}

- (Ogre::SceneNode *) node
{
	return node;
}

- (NSString *) start
{
	return start;
}

- (NSString *) end
{
	return end;
}

- (NSString *) identifier
{
	return identifier;
}

- (void) dealloc
{
	[container release];
	[start release];
	[end release];
	[identifier release];
	[type release];
	[super dealloc];
}

- (BOOL) identifierExists: (NSString *) ide
{
	NSLog (@"%@: %s must be implemented by the subclasses", self, __FUNCTION__);
	return 0;
}

- (void) setPosition: (Ogre::Vector3) vector
{
	node->setPosition (vector);
}

- (Ogre::Vector3) getPosition
{
	return node->getWorldPosition();
}

- (void) setLayout: (Layout *) lay
{
	layout = lay;
	[layout retain];
}

- (void) updateLayout
{
}

- (Layout *) layout
{
	return layout;
}

- (NSString *) type
{
	return type;
}
@end
