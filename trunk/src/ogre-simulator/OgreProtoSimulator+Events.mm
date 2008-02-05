#include "OgreProtoSimulator.h"

@implementation OgreProtoSimulator (Events)
- (XContainer *) findContainerWithName: (NSString *) containerName
{
	XContainer *container;
	/* check to see container where thre new container will be placed */
	if ([containerName isEqual: @"0"]){
		container = root;
	}else{
		container = [root containerWithIdentifier: containerName];
	}

	if (container == nil){
		NSString *str;
		str = [NSString stringWithFormat: @"Container (%@) not created", containerName];
		[[NSException exceptionWithName: @"SimulatorException"
				reason: str userInfo: nil] raise];
	}
	return container;
}

- (void) pajeCreateContainer: (PajeCreateContainer *) e
{
	NSString *containerName = [e container];
	NSString *newContainerName = [e alias];

	XContainer *container, *newContainer;
	container = [self findContainerWithName: containerName];
	newContainer = [root containerWithIdentifier: newContainerName];


	if (newContainer != nil){
		NSString *str; 
		str = [NSString stringWithFormat: @"Container (%@) already exists", containerName];
		 [[NSException exceptionWithName: @"SimulatorException"
			reason: str userInfo: nil] raise];
	}else{
		newContainer = [[XContainer alloc] init];
		[newContainer setIdentifier: newContainerName];
		[newContainer setType: [hierarchy nameToAlias: [e type]]];
		[newContainer setContainer: container];
		[container addSubContainer: newContainer];
		[newContainer release];
	}
}

- (void) pajeDestroyContainer: (PajeDestroyContainer *) e
{
//	NSLog (@"%s", __FUNCTION__);
	NSString *containerName = [e container];
	XContainer *container;
	container = [self findContainerWithName: containerName];
	if (container == nil){
		NSString *str; 
		str = [NSString stringWithFormat: @"Container (%@) was not created", containerName];
//		 [[NSException exceptionWithName: @"SimulatorException"
//			reason: str userInfo: nil] raise];
	}else{
		unsigned int i;
		NSArray *ar = [container states];

		XState *lastState = [container getLastState];
		if (lastState != nil){
			[lastState setEnd: [e time]];
			[lastState setFinalized: YES];
		}
//		NSLog (@"Finalizando %@ - states = %d", containerName, [[container states] count]);
		for (i = 0; i < [ar count]; i++){
			XState *s = (XState *)[ar objectAtIndex: i];
//			NSLog (@"%@ %@ %@ %@ %d", [s identifier], [s type], [s start], [s end], [s finalized]);
		}
	}

}

- (void) pajePushState: (PajePushState *) pps
{
	static long long counter = 0;
	NSString *containerName = [pps container];
	NSString *entityType = [pps entityType];
	NSString *value = [pps value]; 

	XContainer *container = [self findContainerWithName: containerName];

	NSString *ide = [NSString stringWithFormat: @"%@-%@-%d", entityType,
value, counter++];
	XState *state = [[XState alloc] init];

	[state setIdentifier: ide];
	[state setContainer: container];
	[state setStart: [pps time]];
	//[state setEnd: [pps time]];
	[state setType: [hierarchy nameToAlias: value]];

	[container addState: state];
	[state release];
	
//	NSLog (@"%s: container found %@ for state %@(%@)", __FUNCTION__, container, [hierarchy nameToAlias: entityType], [hierarchy nameToAlias: value]);
	
}

- (void) pajePopState: (PajePopState *) pps
{
	NSString *containerName = [pps container];
//	NSString *entityType = [pps entityType];

	XContainer *container = [self findContainerWithName: containerName];
	NSMutableArray *ar = [container states];
	int i;
	for (i = [ar count]-1; i > 0; i--){
		XState *x = [ar objectAtIndex: i];
		if ([x finalized] == NO){
			[x setEnd: [pps time]];
			[x setFinalized: YES];
			break;
		}
	}
	//NSLog (@"%s: container found %@ for state %@", __FUNCTION__, container, entityType);
}

- (void) pajeSetState: (PajeSetState *) pps
{
	static long long counter = 0;
	NSString *containerName = [pps container];
	NSString *entityType = [pps entityType];
	NSString *value = [pps value]; 

	XContainer *container = [self findContainerWithName: containerName];
	XState *lastState = [container getLastState];
	if (lastState != nil){
		[lastState setEnd: [pps time]];
		[lastState setFinalized: YES];
	}

	NSString *ide = [NSString stringWithFormat: @"%@-%@-%d", entityType,
value, counter++];
	XState *state = [[XState alloc] init];

	[state setIdentifier: ide];
	[state setContainer: container];
	[state setStart: [pps time]];
	[state setEnd: [pps time]];
	[state setType: [hierarchy nameToAlias: value]];
	[state setFinalized: NO];

	[container addState: state];
	[state release];
	
//	NSLog (@"%s: container found %@ for state %@(%@)", __FUNCTION__, container, [hierarchy nameToAlias: entityType], [hierarchy nameToAlias: value]);
	
}

- (NSString *) linkIdentifierWithEntityType: (NSString *) e
		andValue: (NSString *) v
{
	static long long counter = 0;
	return [NSString stringWithFormat: @"s%@-%@-%d", e, v, counter++];
}

- (void) updateConnectionsWith: (XLink *) link
{
	/* updating connections between nodes (to help visu graphviz) */
	NSString *sourceName = [[link sourceContainer] identifier];
	NSString *destName = [[link destContainer] identifier];
	NSMutableSet *set = [links objectForKey: sourceName];
	if (set == nil){
		set = [[NSMutableSet alloc] init];
		[links setObject: set forKey: sourceName];
		[set release];
	}
	if (![set containsObject: destName]){
		[set addObject: destName];
		[newLinks setObject: destName
			forKey: sourceName];
	}
}

- (void) pajeStartLink: (PajeStartLink *) p
{
	NSString *containerName = [p container];
	NSString *entityType = [p entityType];
	NSString *value = [p value]; 
	NSString *sourceContainerName = [p sourceContainer]; 
	NSString *key = [p key];	

	XContainer *container = [self findContainerWithName: containerName];
	XContainer *sourceContainer = [self findContainerWithName: sourceContainerName];

	/* Check if there was a pajeEndLink already simulated */
	XLink *link = [container linkWithKey: key];
	if (link == nil){
		XLink *link = [[XLink alloc] init];
		//TODO
		//NSLog (@"%@", [p entityType]); is printed nil
		NSString *ide = [self linkIdentifierWithEntityType: entityType
						andValue: value];
		[link setIdentifier: ide];
		[link setContainer: sourceContainer];
		[link setSourceContainer: sourceContainer];
		[link setStart: [p time]];
		[link setEnd: [p time]];
		[link setType: [hierarchy nameToAlias: value]];
		[link setFinalized: NO];
		[container addLink: link withKey: key];
	}else{
		[link setContainer: sourceContainer];
		[link setSourceContainer: sourceContainer];
		[link setStart: [p time]];
		[link setFinalized: YES];

		[self updateConnectionsWith: link];	
	}
}


- (void) pajeEndLink: (PajeEndLink *) p
{
	NSString *containerName = [p container];
	NSString *entityType = [p entityType];
	NSString *value = [p value]; 
	NSString *destContainerName = [p destContainer]; 
	NSString *key = [p key];	

	XContainer *container = [self findContainerWithName: containerName];
	XContainer *destContainer = [self findContainerWithName: destContainerName];

	XLink *link = [container linkWithKey: key];
	if (link == nil){
		XLink *link = [[XLink alloc] init];
		//TODO
		//NSLog (@"%@", [p entityType]); is printed nil
		NSString *ide = [self linkIdentifierWithEntityType: entityType
						andValue: value];
		[link setIdentifier: ide];
		[link setDestContainer: destContainer];
		[link setStart: [p time]];
		[link setEnd: [p time]];
		[link setType: [hierarchy nameToAlias: value]];
		[link setFinalized: NO];
		[container addLink: link withKey: key];
	}else{
		[link setDestContainer: destContainer];
		[link setEnd: [p time]];
		[link setFinalized: YES];
	
		[self updateConnectionsWith: link];	
	}
}
 

@end
