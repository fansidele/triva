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
	hiddenEntityValues = [[NSMutableDictionary alloc] init];
	enableNotifications = YES;
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
	[hiddenEntityValues release];
	[super dealloc];
}

- (BOOL) isHiddenEntityType: (PajeEntityType *) type
{
	return [hiddenEntityTypes containsObject: type];
}

- (BOOL) isHiddenValue: (NSString *) value forEntityType: (PajeEntityType*)type
{
	NSSet *set = [hiddenEntityValues objectForKey: type];
	if (set){
		return [set containsObject: value];

	}else{
		return NO;
	}
}

- (BOOL) isHiddenContainer: (PajeContainer *) container forEntityType: (PajeEntityType*)type
{
	return [hiddenContainers containsObject: [container name]];
}

- (void) filterEntityType: (PajeEntityType *) type show: (BOOL) show
{
	if (show){
		[hiddenEntityTypes removeObject: type];
	}else{
		[hiddenEntityTypes addObject: type];
	}
	[self entitySelectionChanged];
}

- (void) filterValue: (NSString *) value
	forEntityType: (PajeEntityType *) type
		show: (BOOL) show
{
	NSMutableSet *set = [hiddenEntityValues objectForKey: type];
	if (!set){
		set = [NSMutableSet set];
		[hiddenEntityValues setObject: set forKey: type];
	}
	if (!show){
		[set addObject: value];
	}else{
		[set removeObject: value];
	}
	[self dataChangedForEntityType: type];
}

- (void) filterContainer: (PajeContainer *) container show: (BOOL) show
{
	if (show){
		[hiddenContainers removeObject: [container name]];
	}else{
		[hiddenContainers addObject: [container name]];
	}
	[self containerSelectionChanged];
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
			context: [hiddenEntityValues objectForKey: entityType]]
				autorelease];
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
			context: [hiddenEntityValues objectForKey: entityType]]
				autorelease];
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

/*
- (NSArray *)allValuesForEntityType:(PajeEntityType *)entityType
{
	NSMutableSet *set = [NSMutableSet setWithArray:
		[super allValuesForEntityType: entityType]];
	[set minusSet: hiddenEntityTypes];
	return [set allObjects];
}
*/


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

- (void) entitySelectionChanged
{
	if (enableNotifications){
		[super entitySelectionChanged];
	}
}

- (void) containerSelectionChanged
{
	if (enableNotifications){
		[super containerSelectionChanged];
	}
}

- (void) setNotifications: (BOOL) notifications
{
	enableNotifications = notifications;
}

- (NSArray *)unfilteredObjectsForEntityType:(PajeEntityType *)entityType
{
	return [super allValuesForEntityType:entityType];
}
@end
