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
					[empty setValue: x];
					[empty setPajeEntity: nil];
					[node addChild: empty];
				}else{
					double x = [empty value];
					x -= duration;
					[empty setValue: x];
				}
			}
		}else{
			entity = [[Treemap alloc] init];
			[entity setName: name];
			[entity setParent: node];
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
					[empty setValue: x];
					[empty setPajeEntity: nil];
					[node addChild: empty];
				}else{
					double x = [empty value];
					x -= duration;
					[empty setValue: x];
				}
			}
		}
	}
}

- (Treemap *) pajeHierarchy: (id) instance parent:(Treemap *) parent
{
	Treemap *node = [[Treemap alloc] init];
	PajeEntityType *et = [self entityTypeForEntity: instance];
	[node setName: [instance name]];
	[node setParent: parent];
	[node setPajeEntity: instance];

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
				child = [self pajeHierarchy:sub parent: node];
				
				[node addChild: child];
			}
		}else{
			Treemap *child = [[Treemap alloc] init];
			[child setName: [et name]];
			[child setParent: node];

			[node addChild: child];

			[self timeSliceAt: instance ofType: et withNode: child];
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
	treemap = [self pajeHierarchy: [self rootInstance] parent: nil];
	[treemap retain];
}

- (void) timeLimitsChanged
{
	[self hierarchyChanged];
}

- (Treemap *) treemapWithWidth: (int) width andHeight: (int) height
{
	[self hierarchyChanged];
	if (treemap == nil){
		return nil;
	}else{
		[treemap calculateWithWidth: width andHeight: height];
		return treemap;
	}
}

- (NSString *) descriptionForNode: (Treemap *) node
{
	if (node == nil){
		return nil;
	}
	if ([node pajeEntity] == nil){
		return nil;
	}
	NSMutableString *ret = [NSMutableString string];
	[ret appendString: [[node pajeEntity] value]];
	[ret appendString: @" "];
	[ret appendString: [[[node pajeEntity] container] name]];
	[ret appendString: @" "];
	double timeSlice = [sliceEndTime timeIntervalSinceDate:sliceStartTime];
	double nodeValue = [node value];
	double porcentage = nodeValue/timeSlice * 100;
	[ret appendString: [NSString stringWithFormat: @"%f\%", porcentage]];
	return ret;
}
@end
