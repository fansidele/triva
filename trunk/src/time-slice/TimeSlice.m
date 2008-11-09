#include "TimeSlice.h"

@implementation TimeSlice
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	NSLog (@"%@ initialized", self);
	return self;
}

- (void) timeSliceAt: (id) instance
              ofType: (id) type
            withNode: (TreeValue *) node
{
	NSEnumerator *en3;
	PajeEntity *ent;

	//limitating for now the algorithm to state types
	if (![type isKindOf: [PajeStateType class]]){
		return;
	}

	en3 = [self enumeratorOfEntitiesTyped:type
		inContainer:instance
		fromTime:[self startTime]
		toTime:[self endTime]
		minDuration:0.001];
	while ((ent = [en3 nextObject]) != nil) {
		NSString *name = [ent name];
		float duration = [ent duration];

		TreeValue *entity;
		entity = (TreeValue *)[node searchChildByName: name];
		if (entity){
			[entity addValue: duration];
		}else{
			entity = [[TreeValue alloc] init];
			[entity setName: name];
			[entity setParent: node];
			[entity setValue: duration];
			[node addChild: entity];
		}
	}
}

- (TreeValue *) pajeHierarchy: (id) instance parent:(TreeValue *) parent
{
	TreeValue *node = [[TreeValue alloc] init];
	PajeEntityType *et = [self entityTypeForEntity: instance];
	[node setName: [et name]];
	[node setParent: parent];

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
				TreeValue *child;
				child = [self pajeHierarchy:sub parent: node];
				
				[node addChild: child];
			}
		}else{
			TreeValue *child = [[TreeValue alloc] init];
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
	TreeValue *tree = [self pajeHierarchy: [self rootInstance] parent: nil];
	NSLog (@"%s %@", __FUNCTION__, tree);
}

- (void) timeLimitsChanged
{
	NSLog (@"%s", __FUNCTION__);
}
@end
