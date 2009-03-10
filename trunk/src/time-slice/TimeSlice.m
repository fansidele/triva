#include "TimeSlice.h"

@implementation TimeSlice
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	NSLog (@"%@ initialized", self);
	sliceStartTime = [NSDate dateWithTimeIntervalSinceReferenceDate: 0];
	sliceEndTime = [NSDate dateWithTimeIntervalSinceReferenceDate: 0];

	/* starting configuration */
	fillWithEmptyNodes = NO;
	considerExclusiveDuration = YES;
	return self;
}

- (void) setSliceStartTime: (NSDate *) time
{
	if (sliceStartTime != nil){
		[sliceStartTime release];
	}
	sliceStartTime = time;
	[sliceStartTime retain];
}

- (void) setSliceEndTime: (NSDate *) time
{
	if (sliceEndTime != nil){
		[sliceEndTime release];
	}
	sliceEndTime = time;
	[sliceEndTime retain];
}

- (void) timeSliceAt: (id) instance
              ofType: (id) type
            withNode: (Treemap *) node
{
	NSEnumerator *en3;
	PajeEntity *ent;

	//limitating for now the algorithm to state types
	if (![type isKindOf: [PajeStateType class]]){
		return;
	}

	en3 = [self enumeratorOfEntitiesTyped:type
		inContainer:instance
		fromTime: sliceStartTime
		toTime: sliceEndTime 
		minDuration:0.001];
	while ((ent = [en3 nextObject]) != nil) {
		NSString *name = [ent name];
		NSDate *entSTime = [ent startTime];
		NSDate *entETime = [ent endTime];

		entSTime = [entSTime laterDate: sliceStartTime];
		entETime = [entETime earlierDate: sliceEndTime];

		float duration = [entETime timeIntervalSinceDate: entSTime];

		if (considerExclusiveDuration){
			float exclusiveDuration = [ent exclusiveDuration];
			if (exclusiveDuration < duration){
				duration = exclusiveDuration;
			}
		}

		Treemap *entity;
		entity = (Treemap *)[node searchChildByName: name];
		if (entity){
			[entity addValue: duration];

			if (fillWithEmptyNodes){
				/* updating empty value - 1*/
				Treemap *empty;
				empty = [node searchChildByName: @"NOTHING"];
				if (!empty){
					double x;
					x = [sliceEndTime
						timeIntervalSinceDate:
							sliceStartTime];
					x -= duration;
                                
					Treemap *empty = [[Treemap alloc] init];
					[empty setName: @"NOTHING"];
					[empty setParent: node];
					[empty setDepth: [node depth]+1];
					[empty setValue: x];
					[empty setPajeEntity: nil];
					[node addChild: empty];
				}else{
					double x = [empty val];
					x -= duration;
					[empty setValue: x];
				}
			}
		}else{
			entity = [[Treemap alloc] init];
			[entity setName: name];
			[entity setParent: node];
			[entity setDepth: [node depth]+1];
			[entity setValue: duration];
			[node addChild: entity];
			[entity setPajeEntity: ent]; /* it may have more than
							one entity to the same
							treemap node. we take
							just the first one. */

			if (fillWithEmptyNodes){
				/* updating empty value */
				Treemap *empty;
				empty = [node searchChildByName: @"NOTHING"];
				if (!empty){
					double x;
					x = [sliceEndTime
						timeIntervalSinceDate:
							sliceStartTime];
					x -= duration;
        
					Treemap *empty = [[Treemap alloc] init];
					[empty setName: @"NOTHING"];
					[empty setParent: node];
					[empty setDepth: [node depth]+1];
					[empty setValue: x];
					[empty setPajeEntity: nil];
					[node addChild: empty];
				}else{
					double x = [empty val];
					x -= duration;
					[empty setValue: x];
				}
			}
		}
	}
}

- (Treemap *) createInstanceHierarchy: (id) instance parent:(Treemap *) parent
{
	Treemap *node = [[Treemap alloc] init];
	PajeEntityType *et = [self entityTypeForEntity: instance];
	[node setName: [instance name]];
	[node setParent: parent];
	[node setPajeEntity: instance];
	if (parent != nil){
		[node setDepth: [parent depth] + 1];
	}else{
		[node setDepth: 0];
	}

	NSEnumerator *en;
	en = [[self containedTypesForContainerType:
		[self entityTypeForEntity:instance]] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if ([self isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [self enumeratorOfContainersTyped: et
						    inContainer:instance];
			while ((sub = [en2 nextObject]) != nil) {
				Treemap *child;
				child = [self createInstanceHierarchy: sub
							parent: node];
				
				if ([[child children] count] == 1){
					[node addChild:
						[[child children]
							objectAtIndex: 0]];
				}else{
					[node addChild: child];
				}
			}
		}else{
			[self timeSliceAt: instance ofType: et withNode: node];
		}
        }
	[node autorelease];
	return node;
}

- (void) hierarchyChanged
{
	if (treemap != nil){
		[treemap release];
	}
	treemap = [self createInstanceHierarchy: [self rootInstance]
				parent: nil];
	[treemap retain];
}

- (void) timeLimitsChanged
{
	[self hierarchyChanged];
}

- (Treemap *) treemapWithWidth: (int) width
                     andHeight: (int) height
                      andDepth: (int) depth
{
	[self hierarchyChanged];
	if (treemap == nil){
		return nil;
	}else{
		[self limitTreemap: treemap toDepth: depth]; 
		[treemap calculateWithWidth: width andHeight: height];
		return treemap;
	}
}

- (NSString *) descriptionForNode: (Treemap *) node
{
	NSMutableString *ret = nil;
	if (node == nil){
		return nil;
	}
	ret = [NSMutableString string];
	[ret appendString: [node name]];
	double timeSlice;
	timeSlice = [sliceEndTime timeIntervalSinceDate:sliceStartTime];
	double rootValue = [treemap val];
	double nodeValue = [node val];
	double porcentage = (nodeValue/rootValue * timeSlice)/timeSlice*100;
	if ([node parent] != nil){
		[ret appendString: @" "];
		[ret appendString: [[[node parent] pajeEntity] name]];
	}
	if (![node isKindOfClass: [TreeIntegrated class]]){
		[ret appendString: @" "];
		[ret appendString: [[[node pajeEntity] container] name]];
		[ret appendString: @" "];
	}
	[ret appendString:
		[NSString stringWithFormat: @" %.2f s", porcentage]];
	return ret;
}


/**
 * Internal method used by limitTree. Obtain all children of a certain
 * node putting them into a new array.
 */
- (NSMutableArray *) findAllLeaves: (Treemap *) tree
{
	NSMutableArray *ret = [NSMutableArray new];
	if ([[tree children] count] == 0){
		[ret addObject: tree];
	}else{
		int i;
		NSArray *children = [tree children];
		for (i = 0; i < [children count]; i++){
			[ret addObjectsFromArray:
				[self findAllLeaves:
					[children objectAtIndex: i]]];
		}
	}
	return ret;
}

/**
 * Internal method used by limitTree. This method implements the aggregating
 * algorithm by summarizing the values of the tree nodes listed in the array.
 */
- (NSMutableArray *) summarizeLeaves: (NSArray *) all
{
	/* creating dictionary: key is name, value is value */
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSMutableDictionary *dict2 = [NSMutableDictionary new];
	int i;
	for (i = 0; i < [all count]; i++){
		Treemap *node = [all objectAtIndex: i];
		NSString *name = [node name];
		NSString *value = [dict objectForKey: name];
		if (value == nil){
			value = [NSString stringWithFormat: @"%f",[node val]];
			[dict setObject: value forKey: name];
			if ([node pajeEntity]){
				[dict2 setObject:[node pajeEntity] forKey:name];
			}
		}else{
			double x = [value doubleValue];
			x += [node val];
			value = [NSString stringWithFormat: @"%f", x];
			[dict setObject: value forKey: name];
		}
	}

	/* creating return: an array with Treemap objects */
	NSMutableArray *ret = [NSMutableArray new];
	NSArray *allDictKeys = [dict allKeys];
	for (i = 0; i < [allDictKeys count]; i++){
		NSString *name = [allDictKeys objectAtIndex: i];
		NSString *value = [dict objectForKey: name];

		TreeIntegrated *node = [[TreeIntegrated alloc] init];
		[node setName: name];
		[node setValue: [value doubleValue]];
		[node setPajeEntity: [dict2 objectForKey: name]];
		[ret addObject: node];
		[node release];
	}
	return ret;
}

- (void) limitTreemap: (Treemap *) tree toDepth: (int) depth
{
	if ([tree depth] == depth && [tree depth] != [treemap maxDepth]){
		/* summarize */
		NSArray *allLeaves = [self findAllLeaves: tree];
		[tree removeAllChildren];
		NSArray *sumLeaves = [self summarizeLeaves: allLeaves];
		int i;
		for (i = 0; i < [sumLeaves count]; i++){
			Treemap *child = [sumLeaves objectAtIndex: i];
			[child setParent: tree];
			[child setDepth: [tree depth]+1];
			[tree addChild: child];
		}
		return;
	}

	/* recurse */
	int i;
	NSArray *children = [tree children];
	for (i = 0; i < [children count]; i++){
		Treemap *child = [children objectAtIndex: i];
		[self limitTreemap: child toDepth: depth];
	}
}
@end
