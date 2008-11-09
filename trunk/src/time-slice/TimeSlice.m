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
		fromTime:[self startTime]
		toTime:[self endTime]
		minDuration:0.001];
	while ((ent = [en3 nextObject]) != nil) {
		NSString *name = [ent name];
		float duration = [ent duration];

		Treemap *entity;
		entity = (Treemap *)[node searchChildByName: name];
		if (entity){
			[entity addValue: duration];
		}else{
			entity = [[Treemap alloc] init];
			[entity setName: name];
			[entity setParent: node];
			[entity setValue: duration];
			[node addChild: entity];
		}
	}
}

- (Treemap *) pajeHierarchy: (id) instance parent:(Treemap *) parent
{
	Treemap *node = [[Treemap alloc] init];
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
	if (treemap == nil){
		return nil;
	}else{
		[treemap calculateWithWidth: width andHeight: height];
		return treemap;
	}
}
@end
