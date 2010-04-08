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

/* VARIABLE: consider time-interval and value to aggregate */
- (void) timeSliceOfVariableAt: (id) instance
		withType: (id) type
		withNode: (TimeSliceTree *) node
{
	NSMutableDictionary *timeSliceValues = nil;
	NSMutableDictionary *timeSliceColors = nil;
	NSString *name = [type name]; //the name is the variable type name
	double integrated = 0;
	id ent = nil;

	//getting the existing timeSliceValues for this node
	timeSliceValues = [node timeSliceValues];	
	if (!timeSliceValues){
		timeSliceValues = [NSMutableDictionary dictionary];
		[node setTimeSliceValues: timeSliceValues];
	}
	timeSliceColors = [node timeSliceColors];
	if (!timeSliceColors){
		timeSliceColors = [NSMutableDictionary dictionary];
		[node setTimeSliceColors: timeSliceColors];
	}

	NSEnumerator *en;
	en = [self enumeratorOfEntitiesTyped:type
		inContainer:instance
		fromTime: sliceStartTime
		toTime: sliceEndTime 
		minDuration:0];
	while ((ent = [en nextObject]) != nil) {
		NSDate *start = [ent startTime];
		NSDate *end = [ent endTime];

		//controlling the time-slice border
		start = [start laterDate: sliceStartTime];
		end = [end earlierDate: sliceEndTime];

		//calculting the duration and getting value
		double duration = [end timeIntervalSinceDate: start];
		double value = [[ent value] doubleValue];

		//integrating in time
		integrated += duration * value;
	}
	[timeSliceValues setValue: [NSNumber numberWithDouble: integrated]
			   forKey: name];
	[timeSliceColors setValue: [self colorForEntityType: type] forKey: name];
}

/* STATE: consider only time-interval to aggregate */
- (void) timeSliceOfStateAt: (id) instance
		withType: (id) type
		withNode: (TimeSliceTree *) node
{
	NSMutableDictionary *timeSliceValues = nil;
	NSMutableDictionary *timeSliceColors = nil;
	NSEnumerator *en = nil;
	id ent = nil;

	//getting the existing timeSliceValues for this node
	timeSliceValues = [node timeSliceValues];	
	if (!timeSliceValues){
		timeSliceValues = [NSMutableDictionary dictionary];
		[node setTimeSliceValues: timeSliceValues];
	}
	timeSliceColors = [node timeSliceColors];
	if (!timeSliceColors){
		timeSliceColors = [NSMutableDictionary dictionary];
		[node setTimeSliceColors: timeSliceColors];
	}

	//intializing state values to zero (in timeSliveValues dict) if they do not exist yet
	NSArray *allValuesOfStateType = [self allValuesForEntityType: type];
	en = [allValuesOfStateType objectEnumerator];
	while ((ent = [en nextObject]) != nil) {
		NSString *currentValue = [timeSliceValues objectForKey: ent];
		if (!currentValue) {
			[timeSliceValues setObject: [NSNumber numberWithDouble: 0]
					    forKey: ent];
		}
	}
	//setting colors for values of the entity type
	en = [allValuesOfStateType objectEnumerator];
	while ((ent = [en nextObject]) != nil) {
		[timeSliceColors setObject: [self colorForValue: ent
						   ofEntityType: type]
			forKey: ent];
	}

	//integrating in time for the selected time slice
	en = [self enumeratorOfEntitiesTyped:type
		inContainer:instance
		fromTime: sliceStartTime
		toTime: sliceEndTime 
		minDuration:0];
	while ((ent = [en nextObject]) != nil) {
		NSDate *start = [ent startTime];
		NSDate *end = [ent endTime];
		NSString *name = [ent value]; //the name is the value of state

		//controlling the time-slice border
		start = [start laterDate: sliceStartTime];
		end = [end earlierDate: sliceEndTime];

		//calculting the duration and getting value
		double duration = [end timeIntervalSinceDate: start];

		if (considerExclusiveDuration){
			float exclusiveDuration = [ent exclusiveDuration];
			if (exclusiveDuration < duration){
				duration = exclusiveDuration;
			}
		}

		//integrating the value of state in time
		double integrated = 1 * duration; //value of state is 1

		//getting the current value
		double value = [[timeSliceValues objectForKey: name] doubleValue];
		value += integrated;

		//saving in the timeSliceValues dict
		[timeSliceValues setObject: [NSNumber numberWithDouble: value]
				    forKey: name];
	}
}

		

- (void) timeSliceAt: (id) instance
              ofType: (id) type
            withNode: (TimeSliceTree *) node
{
	if ([type isKindOf: [PajeVariableType class]]){
		[self timeSliceOfVariableAt: instance
			withType: type
			withNode: node];
	}else if ([type isKindOf: [PajeStateType class]]){
		[self timeSliceOfStateAt: instance
			withType: type
			withNode: node];
	}
	return;
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
