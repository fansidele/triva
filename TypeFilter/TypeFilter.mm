#include "TypeFilter.h"
#include "TypeFilterWindow.h"
#include "General/FilteredEnumerator.h"

static TypeFilterWindow *window = NULL;

@implementation TypeFilter
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	window = new TypeFilterWindow ((wxWindow*)NULL);
	window->setController (self);
	window->Show();

	hiddenEntityTypes = [[NSMutableSet alloc] init];
	hiddenContainers = [[NSMutableSet alloc] init];
	return self;
}

- (void) hierarchyChanged
{
	window->HierarchyChanged();
	[super hierarchyChanged];
}

- (void)dealloc
{
	[hiddenEntityTypes release];
	[hiddenContainers release];
	[super dealloc];
}

- (BOOL) isHiddenEntityType: (PajeEntityType *) type
{
	return [hiddenEntityTypes containsObject: type];
}

- (BOOL) isHiddenValue: (NSString *) value forEntityType: (PajeEntityType*)type
{
	return [hiddenEntityTypes containsObject: value];
}

- (BOOL) isHiddenContainer: (PajeContainer *) container forEntityType: (PajeEntityType*)type
{
	return [hiddenContainers containsObject: container];
}

- (void) hideEntityType: (PajeEntityType *) type
{
	[hiddenEntityTypes addObject: type];
	if ([self isContainerEntityType: type]){
		[super containerSelectionChanged];
	}else{
		[super entitySelectionChanged];
	}
}

- (void) showEntityType: (PajeEntityType *) type
{
	[hiddenEntityTypes removeObject: type];
	if ([self isContainerEntityType: type]){
		[super containerSelectionChanged];
	}else{
		[super entitySelectionChanged];
	}
}

- (void) hideValue: (NSString *) value forEntityType: (PajeEntityType *) type
{
	[hiddenEntityTypes addObject: value];
	[super entitySelectionChanged];
}

- (void) showValue: (NSString *) value forEntityType: (PajeEntityType *) type
{
	[hiddenEntityTypes removeObject: value];
	[super entitySelectionChanged];
}

- (void) hideContainer: (PajeContainer *) container
{
	[hiddenContainers addObject: [container name]];
	[super containerSelectionChanged];
}

- (void) showContainer: (PajeContainer *) container
{
	[hiddenContainers removeObject: [container name]];
	[super containerSelectionChanged];
}

/* filtered queries */
- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType
{
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	[ret addObjectsFromArray: 
		[super containedTypesForContainerType: containerType]];

	NSEnumerator *en = [ret objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject])){
		if ([hiddenEntityTypes containsObject: et]){
			[ret removeObjectIdenticalTo: et];
		}
	}
	[ret autorelease];
	return ret;
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
	NSEnumerator *origEnum;
	origEnum = [super enumeratorOfEntitiesTyped: entityType
   			     inContainer: container
				fromTime: start
				  toTime: end
			     minDuration: minDuration];
	return [[[FilteredEnumerator alloc]
			initWithEnumerator:origEnum
			filter: self
			selector:@selector(filterHiddenEntity:filter:)
			context:hiddenEntityTypes] autorelease];
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)entityType
                                        inContainer:(PajeContainer *)container
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
                                        minDuration:(double)minDuration
{
	NSEnumerator *origEnum;
	origEnum = [super enumeratorOfCompleteEntitiesTyped: entityType
   			     inContainer: container
				fromTime: start
				  toTime: end
			     minDuration: minDuration];
	return [[[FilteredEnumerator alloc]
			initWithEnumerator:origEnum
			filter: self
			selector:@selector(filterHiddenEntity:filter:)
			context:hiddenEntityTypes] autorelease];
}

- (NSEnumerator *)enumeratorOfContainersTyped:(PajeEntityType *)entityType
                                  inContainer:(PajeContainer *)container
{
	NSEnumerator *origEnum;
	origEnum = [super enumeratorOfContainersTyped: entityType
					  inContainer: container];
	return [[[FilteredEnumerator alloc]
			initWithEnumerator:origEnum
			filter: self
			selector:@selector(filterHiddenContainer:filter:)
			context:hiddenContainers] autorelease];
}

- (id)filterHiddenEntity:(PajeEntity *)entity
	filter:(NSSet *)filter
{
	if ([filter containsObject:[self valueForEntity:entity]]) {
		return nil;
	}else{
		return entity;
	}
}

- (id)filterHiddenContainer:(PajeContainer *)container
	filter:(NSSet *)filter
{
	if ([filter containsObject: [container name]]){
		return nil;
	}else{
		return container;
	}
}

- (PajeFilter *) inputComponent
{
	return inputComponent;
}
@end
