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
			NSEnumerator *en3;
			PajeEntity *ent;

			TreeValue *child = [[TreeValue alloc] init];
			[child setName: [et name]];
			[child setParent: node];

			[node addChild: child];

			en3 = [self enumeratorOfEntitiesTyped:et
				inContainer:instance
				fromTime:[self startTime]
				toTime:[self endTime]
				minDuration:0.001];
			while ((ent = [en3 nextObject]) != nil) {
				NSString *name = [ent name];
				float duration = [ent duration];

				TreeValue *instance;
				instance = (TreeValue *)[child
						searchChildByName: name];
				if (instance){
					[instance addValue: duration];
				}else{
					instance = [[TreeValue alloc] init];
					[instance setName: name];
					[instance setParent: child];
					[instance setValue: duration];
					[child addChild: instance];
				}
			}
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
