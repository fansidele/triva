#include "TimeSliceAggregation.h"

@implementation TimeSliceAggregation
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	sliceStartTime = [NSDate dateWithTimeIntervalSinceReferenceDate: 0];
	sliceEndTime = [NSDate dateWithTimeIntervalSinceReferenceDate: 0];

	/* starting configuration */
	considerExclusiveDuration = YES;
	tree = nil;
	
	return self;
}

- (void) timeSliceAt: (id) instance
              ofType: (id) type
            withNode: (TimeSliceTree *) node
{
	NSEnumerator *en3;
	PajeEntity *ent;
	NSMutableDictionary *nodeValues;
	NSMutableDictionary *nodeEntities;

	nodeValues = [[NSMutableDictionary alloc] init];
	nodeEntities = [[NSMutableDictionary alloc] init];

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

		NSString *val = (NSString *)[nodeValues objectForKey: name];
		if (val){
			float value = [val floatValue];
			value += duration;
			NSString *newVal;
			newVal = [NSString stringWithFormat: @"%f", value];
			[nodeValues setObject: newVal forKey: name];	
		}else{
			NSString *newVal;
			newVal = [NSString stringWithFormat: @"%f", duration];
			[nodeValues setObject: newVal forKey: name];	
		}

		//defining paje entities
		if (![nodeEntities objectForKey: name]){
			[nodeEntities setObject: ent forKey: name];
		}
	}
	[node setPajeEntities: nodeEntities];
	[node setTimeSliceValues: nodeValues];
	[nodeValues release];
	[nodeEntities release];
}

- (TimeSliceTree *) createInstanceHierarchy: (id) instance
				     parent: (TimeSliceTree *) parent
{
	TimeSliceTree *node = [[TimeSliceTree alloc] init];
	PajeEntityType *et = [self entityTypeForEntity: instance];
	[node setName: [instance name]];
	[node setParent: parent];
	//[node setPajeEntity: instance];
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
				TimeSliceTree *child;
				child = [self createInstanceHierarchy: sub
							parent: node];
				
/*
				if ([[child children] count] == 1){
					[node addChild:
						[[child children]
							objectAtIndex: 0]];
				}else{
*/
					[node addChild: child];
//				}
			}
		}else{
			[self timeSliceAt: instance ofType: et withNode: node];
		}
        }
	[node autorelease];
	return node;
}

- (void) setSliceStartTime: (NSDate *) time
{
	if (sliceStartTime != nil){
		[sliceStartTime release];
	}
	sliceStartTime = time;
	[sliceStartTime retain];
	sliceTimeChanged = YES;
}

- (void) setSliceEndTime: (NSDate *) time
{
	if (sliceEndTime != nil){
		[sliceEndTime release];
	}
	sliceEndTime = time;
	[sliceEndTime retain];
	sliceTimeChanged = YES;
}

- (void) timeSelectionChanged
{
	NSLog (@"%s - %@,%@", __FUNCTION__,
		[self selectionStartTime],
		[self selectionEndTime]);
	BOOL timeSliceChanged = NO;
	if ([sliceStartTime isEqualToDate: [self selectionStartTime]] == NO){
		[sliceStartTime release];
		sliceStartTime = [self selectionStartTime];
		[sliceStartTime retain];
		timeSliceChanged = YES;
	}
	if ([sliceEndTime isEqualToDate: [self selectionEndTime]] == NO){
		[sliceEndTime release];
		sliceEndTime = [self selectionEndTime];
		[sliceEndTime retain];
		timeSliceChanged = YES;
	}
	if (timeSliceChanged == YES){
		NSLog (@"Calculating behavioral hierarchy...");
		/* re-create hierarchy */
		if (tree){
			[tree release];
		}
		tree = [self createInstanceHierarchy: [self rootInstance]
					      parent: nil];	
		/* aggregate values */
		[tree doAggregation];
		NSLog (@"Done");
	}
	/* let notification goes on */
	[outputComponent timeSelectionChanged];
}

/*
- (Tree *) treemapWithWidth: (int) width
                     andHeight: (int) height
                      andDepth: (int) depth
			andValues: (NSSet *) values
{
	if (width == 0 || height == 0 || width > 1000000 || height > 1000000
		|| values == nil){
		return nil;
	}

	if (sliceTimeChanged){
		NSLog (@"sliceTimeChanged = true, re-creating hierarchy,"
			" aggregation: this might take time depending "
			"how big the hierarchy is");
		if (tree != nil){
			[tree release];
		}
		tree = [self createInstanceHierarchy: [self rootInstance]
				parent: nil];
		[tree retain];
		sliceTimeChanged = NO;
	}

	if (tree == nil){
		return nil;
	}else{
		[tree recursiveRemoveAllAggregatedChildren];
		[tree recalculateWithValues: values];
		int maxDepth = [tree maxDepth], i;
		for (i = 0; i < maxDepth; i++){
			[self limitTree: tree
				toDepth: i toValues: values]; 
		}
//		[treemap calculateTreemapWithWidth: width
//				andHeight: height];
		return tree;
	}
}
*/

/**
 * Internal method used by limitTree. Obtain all children of a certain
 * node putting them into a new array.
 */
/**
 * Internal method used by limitTree. This method implements the aggregating
 * algorithm by summarizing the values of the tree nodes listed in the array.
 */
/*
- (NSMutableArray *) findAllLeaves: (TimeSliceTree *) treex
{
	NSMutableArray *ret = [NSMutableArray new];
	if ([[treex children] count] == 0){
		[ret addObject: treex];
	}else{
		int i;
		NSArray *children = [treex children];
		for (i = 0; i < [children count]; i++){
			[ret addObjectsFromArray:
				[self findAllLeaves:
					[children objectAtIndex: i]]];
		}
	}
	return ret;
}

- (NSMutableArray *) summarizeLeaves: (NSArray *) all
{
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSMutableDictionary *dict2 = [NSMutableDictionary new];
	int i;
	for (i = 0; i < [all count]; i++){
		TimeSliceTree *node = [all objectAtIndex: i];
		NSString *name = [node name];
		NSString *value = [dict objectForKey: name];
		if (value == nil){
			value = [NSString stringWithFormat: @"%f",
							[node usedVal]];
			[dict setObject: value forKey: name];
			if ([node pajeEntity]){
				[dict2 setObject:[node pajeEntity] forKey:name];
			}
		}else{
			double x = [value doubleValue];
			x += [node usedVal];
			value = [NSString stringWithFormat: @"%f", x];
			[dict setObject: value forKey: name];
		}
	}

	NSMutableArray *ret = [NSMutableArray new];
	NSArray *allDictKeys = [dict allKeys];
	for (i = 0; i < [allDictKeys count]; i++){
		NSString *name = [allDictKeys objectAtIndex: i];
		NSString *value = [dict objectForKey: name];

		TimeSliceTree *node = [[TimeSliceTree alloc] init];
		[node setName: name];
		[node setValue: [value doubleValue]];
		[node setPajeEntity: [dict2 objectForKey: name]];
		[ret addObject: node];
		[node release];
	}
	return ret;
}

- (void) limitTree: (TimeSliceTree *) treex toDepth: (int) depth
{
	if ([treex depth] == depth && [treex depth] != [treex maxDepth]){
		NSArray *allLeaves = [self findAllLeaves: treex];
		NSArray *sumLeaves = [self summarizeLeaves: allLeaves];
		int i;
		for (i = 0; i < [sumLeaves count]; i++){
			TimeSliceTree *child = [sumLeaves objectAtIndex: i];
			if ([values containsObject:[[child pajeEntity] value]] 
				|| [values count] == 0){
				[child setParent: treex];
				[child setUsedValue: [child val]];
				[treex addAggregatedChild: child];
			}
		}
		return;
	}

	int i;
	NSArray *children = [treex children];
	for (i = 0; i < [children count]; i++){
		TimeSliceTree *child = [children objectAtIndex: i];
		[self limitTree: child toDepth: depth toValues: values];
	}
}
*/

- (TimeSliceTree *) timeSliceTree
{
	return tree;
}
@end
