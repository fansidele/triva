/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "TimeSliceAggregation.h"

@implementation TimeSliceAggregation
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	sliceStartTime = [NSDate dateWithTimeIntervalSinceReferenceDate: 0];
	sliceEndTime = [NSDate dateWithTimeIntervalSinceReferenceDate: 0];

	nodeNames = [[NSMutableDictionary alloc] init];

	/* starting configuration */
	considerExclusiveDuration = YES;
	tree = nil;
	graphAggregationEnabled = YES;
	
	return self;
}

/* VARIABLE: consider time-interval and value to aggregate */
- (void) timeSliceOfVariableAt: (id) instance
		withType: (id) type
		withNode: (TimeSliceTree *) node
{
	NSMutableDictionary *timeSliceValues = nil;
	NSMutableDictionary *timeSliceColors = nil;
	NSMutableDictionary *timeSliceTypes = nil;
	NSMutableDictionary *timeSliceDurations = nil;
	NSString *name = [type name]; //the name is the variable type name
	double integrated = 0;
	id ent = nil;

	//getting the existing timeSliceValues for this node
	timeSliceValues = [node timeSliceValues];	
	timeSliceColors = [node timeSliceColors];
	timeSliceTypes = [node timeSliceTypes];
	timeSliceDurations = [node timeSliceDurations];

	NSEnumerator *en;
	en = [self enumeratorOfEntitiesTyped:type
		inContainer:instance
		fromTime: sliceStartTime
		toTime: sliceEndTime 
		minDuration:0];
	double accumDuration = 0;
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

		if (value){
			accumDuration += duration;
		}
	}
	[timeSliceDurations setValue: [NSNumber numberWithDouble: accumDuration]
				forKey: name];
	[timeSliceValues setValue: [NSNumber numberWithDouble: integrated]
			   forKey: name];
	[timeSliceColors setValue: [self colorForEntityType: type] forKey: name];
	[timeSliceTypes setObject: type forKey: name];
}

/* STATE: consider only time-interval to aggregate */
- (void) timeSliceOfStateAt: (id) instance
		withType: (id) type
		withNode: (TimeSliceTree *) node
{
	NSMutableDictionary *timeSliceValues = nil;
	NSMutableDictionary *timeSliceColors = nil;
	NSMutableDictionary *timeSliceTypes = nil;
	NSMutableDictionary *timeSliceDurations = nil;
	NSEnumerator *en = nil;
	id ent = nil;

	//getting the existing timeSliceValues for this node
	timeSliceValues = [node timeSliceValues];	
	timeSliceColors = [node timeSliceColors];
	timeSliceTypes = [node timeSliceTypes];
	timeSliceDurations = [node timeSliceDurations];

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
		[timeSliceTypes setObject: type forKey: ent];
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
		double value = [[timeSliceValues objectForKey: name]
					doubleValue];
		value += integrated;

		//saving in the timeSliceValues dict
		[timeSliceValues setObject: [NSNumber numberWithDouble: value]
				    forKey: name];

		//getting current accumulated duration for this name
		if (value){
			double acc;
			acc = [[timeSliceDurations objectForKey: name]
					doubleValue];
			acc += duration;
			[timeSliceDurations setObject:
					[NSNumber numberWithDouble:acc]
				forKey: name];
		}
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

/* LINK: consider only time-interval to aggregate */
- (void) timeSliceOfLinkAt: (id) instance
		withType: (id) type
		withNode: (TimeSliceTree *) node
{
	NSEnumerator *en = nil;
	id ent = nil;

	//integrating in time for the selected time slice
	en = [self enumeratorOfEntitiesTyped:type
		inContainer:instance
		fromTime: sliceStartTime
		toTime: sliceEndTime 
		minDuration:0];
	while ((ent = [en nextObject]) != nil) {
		NSString *source = [[ent sourceContainer] name];
		NSString *dest = [[ent destContainer] name];

		//getting source and dest nodes
		TimeSliceTree *sourceNode;
		TimeSliceTree *destNode;
		sourceNode = (TimeSliceTree*)[nodeNames objectForKey: source];
		destNode = (TimeSliceTree*)[nodeNames objectForKey: dest];

		//get edge for destNode
		TimeSliceGraph *edge = nil;
		edge = (TimeSliceGraph *)[[sourceNode destinations]
				objectForKey: dest];
		if (edge == nil){
			edge = [[TimeSliceGraph alloc] init];
			[edge setName: [NSString stringWithFormat: @"%@#%@",
				source, dest]];

			NSMutableDictionary *timeSliceColors = nil;
			timeSliceColors = [edge timeSliceColors];

			//setting colors for values of the entity type
			NSArray *allValuesOfType;
			allValuesOfType = [self allValuesForEntityType: type];
			NSEnumerator *en3;
			id val;
			en3 = [allValuesOfType objectEnumerator];
			while ((val = [en3 nextObject]) != nil) {
				[timeSliceColors setObject:
					[self colorForValue: val
					      ofEntityType: type]
						forKey: val];
			}

			//register the edge by destNode
			[[sourceNode destinations] setObject:edge
						      forKey:dest];
			[edge release];
		}

		//lets aggregated in time
		NSDate *start = [ent startTime];
		NSDate *end = [ent endTime];
		//controlling the time-slice border
		start = [start laterDate: sliceStartTime];
		end = [end earlierDate: sliceEndTime];

		//calculting the duration and getting value
		double duration = [end timeIntervalSinceDate: start];
		double integrated;
		if (duration){
			integrated = duration * 1; //value of 1 for each link
		}else{
			integrated = 1; //TODO: if duration=0, just count links
		}
		
		NSMutableDictionary *timeSliceValues = nil;
		NSMutableDictionary *timeSliceDurations = nil;

		//getting the existing timeSliceValues for this node
		timeSliceValues = [edge timeSliceValues];	
		timeSliceDurations = [edge timeSliceDurations];

		//the name is the value of the link
		NSString *name = [ent value];

		//getting the current value
		double value = [[timeSliceValues objectForKey: name]
					doubleValue];
		value += integrated;

		//saving in the timeSliceValues dict
		[timeSliceValues setObject: [NSNumber numberWithDouble: value]
				    forKey: name];

		//getting current accumulated duration for this name
		if (value){
			double acc;
			acc = [[timeSliceDurations objectForKey: name]
					doubleValue];
			acc += duration;
			[timeSliceDurations setObject:
					[NSNumber numberWithDouble:acc]
				forKey: name];
		}
	}
}

- (void) createGraphBasedOnLinks: (id) instance
			withTree: (TimeSliceTree *) node
{
	PajeEntityType *et = [self entityTypeForEntity: instance];
	NSEnumerator *en;
	en = [[self containedTypesForContainerType: et] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if ([self isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [self enumeratorOfContainersTyped: et
						    inContainer:instance];
			while ((sub = [en2 nextObject]) != nil) {
				TimeSliceTree *child;
				child = (TimeSliceTree*)[nodeNames objectForKey: [sub name]];
				[self createGraphBasedOnLinks: sub
						withTree: child];
			}
		}else{
			if ([et isKindOfClass: [PajeLinkType class]]){
				[self timeSliceOfLinkAt: instance
					withType: et
					withNode: node];
			}
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
	//saving node name in the nodeNames dict
	[nodeNames setObject: node forKey: [node name]];

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

- (void) calculateBehavioralHierarchy
{
//	NSLog (@"Calculating behavioral hierarchy...");
	/* re-create hierarchy */
	if (tree){
		[tree release];
		[nodeNames release];
		nodeNames = [[NSMutableDictionary alloc] init];
	}
	tree = [self createInstanceHierarchy: [self rootInstance]
				      parent: nil];	

	if (graphAggregationEnabled){
		[self createGraphBasedOnLinks: [self rootInstance]
			 withTree: tree];
	}

	[tree retain];
	/* aggregate values */
	[tree doAggregation];

	/* calculate the final value of the nodes (to be used by treemap)*/
	[tree doFinalValue];

	if (graphAggregationEnabled){
		[tree doGraphAggregationWithNodeNames: nodeNames];
	}
//	NSLog (@"Done");
}

- (void) timeSelectionChanged2
{
//	NSLog (@"%s - %@,%@", __FUNCTION__,
//		[self selectionStartTime],
//		[self selectionEndTime]);
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
		[self calculateBehavioralHierarchy];
	}
	/* let notification goes on */
	[outputComponent timeSelectionChanged];
}

-(void)timeSelectionChanged
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
/*
	GSDebugAllocationActive(YES);
	if (1){
		Class *array = GSDebugAllocationClassList();
		int i;
		for (i=0;array[i];i++){
			NSLog (@"%d %@\n", GSDebugAllocationPeak (array[i]),
				array[i]);
		}
		NSLog (@"");
	}else{
		[self activateRecordingOfClass: @"GSCInlineString"];
		[self listRecordedObjectsOfClass: @"GSCInlineString"];
	}
*/
	[self timeSelectionChanged2];
	[pool release];
}

- (void) entitySelectionChanged
{
	[self calculateBehavioralHierarchy];
	[super entitySelectionChanged];
}

- (void) containerSelectionChanged
{
	[self calculateBehavioralHierarchy];
	[super containerSelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
	[self calculateBehavioralHierarchy];
	[super dataChangedForEntityType: type];
}

- (TimeSliceTree *) timeSliceTree
{
	return tree;
}

- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container
{
	NSLog (@"DEBUG START");
	NSLog (@"slice (%@ - %@)", sliceStartTime, sliceEndTime);
	NSLog (@"type = %@ container = %@", [type name], [container name]);
	NSEnumerator *en;
	id ent;
	en = [self enumeratorOfEntitiesTyped:type
		inContainer: container
		fromTime: sliceStartTime
		toTime: sliceEndTime 
		minDuration:0];
	double integrated = 0;
	while ((ent = [en nextObject]) != nil) {
		NSDate *start = [ent startTime];
                NSDate *end = [ent endTime];

                //controlling the time-slice border
                start = [start laterDate: sliceStartTime];
                end = [end earlierDate: sliceEndTime];

		double value = [[ent value] doubleValue];
		double duration = [end timeIntervalSinceDate: start];
		integrated += duration * value;

//		NSLog (@"\tint(%@ - %@) dur = %f val = %f",
		if(value){
		NSLog (@"\tdur = %f val = %f",
//			start, end, duration, value);
			duration, value);
		}
	}
	NSLog (@"integrated value = %f", integrated);
	NSLog (@"DEBUG END");
}
@end
