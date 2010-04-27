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
@end
