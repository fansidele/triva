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


	nodeValues = [node timeSliceValues];	
	if (!nodeValues){
		nodeValues = [NSMutableDictionary dictionary];
		[node setTimeSliceValues: nodeValues];
	}
	nodeEntities = [node pajeEntities];
	if (!nodeEntities){
		nodeEntities = [NSMutableDictionary dictionary];
		[node setPajeEntities: nodeEntities];
	}

	//limitating for now the algorithm to state types
	if (!([type isKindOf: [PajeVariableType class]] ||
		[type isKindOf: [PajeStateType class]])){
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

		if ([name isEqualToString: @""]){
			name = [ent entityType];
		}

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
				[node addChild: child];
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


- (void) debug
{
	GSDebugAllocationActive(YES);
	Class *x = GSDebugAllocationClassList();
	int i = 0;
	while (1&&x[i]){
		 NSLog (@"%@ - %d\n", x[i],
		 GSDebugAllocationPeak(x[i]));
		 i++;
	}
}

- (void) activateRecordingOfClass: (NSString *)classname
{
	Class *x = GSDebugAllocationClassList();
	int i = 0;
	while (1&&x[i]){
		 if ([[x[i] description] isEqualToString: classname]){
				 GSDebugAllocationActiveRecordingObjects(x[i]);
		 }
		 i++;
	}
}

- (void) listRecordedObjectsOfClass: (NSString *) classname
{
	Class *x = GSDebugAllocationClassList();
	int i = 0;
	while (1&&x[i]){
		 if ([[x[i] description] isEqualToString: classname]){
				 NSLog (@"%@ => %d (peak:%d)", x[i],
				 [[[GSDebugAllocationListRecordedObjects(x[i])
				 	objectEnumerator]
				 allObjects] count],
				 GSDebugAllocationPeak(x[i]));
				 NSEnumerator *en;
				 en =[GSDebugAllocationListRecordedObjects(x[i])
				 	objectEnumerator];
				 id obj;
				 while ((obj = [en nextObject])){
					NSLog (@"\t%@", obj);
				 }
		 }
		 i++;
	}
}

-(void)timeSelectionChanged
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//[self debug];
	//[self activateRecordingOfClass: @"TimeSliceTree"];
	[self timeSelectionChanged2];
	//[self listRecordedObjectsOfClass: @"TimeSliceTree"];
	[pool release];
}



- (void) timeSelectionChanged2
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
	        [tree retain];
		/* aggregate values */
		[tree doAggregation];
		NSLog (@"Done");
	}
	/* let notification goes on */
	[outputComponent timeSelectionChanged];
}

- (TimeSliceTree *) timeSliceTree
{
	return tree;
}
@end
