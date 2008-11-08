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

- (Tree *) pajeHierarchy: (id) instance parent:(Tree *) parent
{
	Tree *node = [[Tree alloc] init];
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
				Tree *child;
				child = [self pajeHierarchy:sub parent: node];
				
				[node addChild: child];
			}
		}else{
			Tree *child = [[Tree alloc] init];
			[child setName: [et name]];
			[child setParent: node];

			[node addChild: child];

//			NSLog (@"child %@ from parent %@", [child name],
//					[[child parent] name]);
		}
        }
	[node autorelease];
	return node;
}

- (void) hierarchyChanged
{
	Tree *tree = [self pajeHierarchy: [self rootInstance] parent: nil];
	NSLog (@"%s %@", __FUNCTION__, tree);
}

- (void) timeLimitsChanged
{
	NSLog (@"%s", __FUNCTION__);
}
@end
