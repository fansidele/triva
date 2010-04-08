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
#include "TypeFilter.h"
//#include "TypeFilterWindow.h"
#include "General/FilteredEnumerator.h"

//static TypeFilterWindow *window = NULL;

@implementation TypeFilter
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
		[NSBundle loadNibNamed: @"TypeFilter" owner: self];
	}
	NSLog (@"%@", browser);
	[browser setDelegate: self];
/*
	window = new TypeFilterWindow ((wxWindow*)NULL);
	window->setController (self);
	window->Show();
*/

	hiddenEntityTypes = [[NSMutableSet alloc] init];
	hiddenContainers = [[NSMutableSet alloc] init];
	hiddenEntityValues = [[NSMutableDictionary alloc] init];
	enableNotifications = YES;
	return self;
}

//browser delegate
- (NSArray *) entityTypesFrom: (PajeEntityType*) type
                    withLevel: (int) level
                  targetLevel: (int) targetLevel
{
	NSMutableArray *ret = [NSMutableArray array];
	if (level == targetLevel){
		[ret addObjectsFromArray:
			[self containedTypesForContainerType: type]];
	}else{
		NSEnumerator *en = [[self containedTypesForContainerType: type]
					objectEnumerator];
		id child;
		while ((child = [en nextObject])){
			[ret addObjectsFromArray:
				[self entityTypesFrom: child
                                            withLevel: level+1
                                          targetLevel: targetLevel]];
		}
	}
	return ret;
}

- (BOOL)browser:(NSBrowser *)sender selectCellWithString:(NSString *)title inColumn:(NSInteger)column
{
	NSLog (@"%s %@ %d", __FUNCTION__, title, column);
	return YES;
}

- (BOOL)browser:(NSBrowser *)sender selectRow:(NSInteger)row inColumn:(NSInteger)column
{
	NSLog (@"%s %d %d", __FUNCTION__, row, column);
	return YES;
}



- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
	NSLog (@"%s %d selected = %@", __FUNCTION__, column, [browser selectedCell]);
	PajeEntityType *type;
	if ([browser selectedCell]){
		NSString *name = [[browser selectedCell] stringValue];
		type = [self entityTypeWithName: name];
	}else{
		type = [[self rootInstance] entityType];
	}
	if ([self isContainerEntityType: type]){
		return [[self containedTypesForContainerType: type] count];
	}else{
		return [[self allValuesForEntityType: type] count];
	}
	return 1;

/*
	NSString *name = [[browser selectedCell] stringValue];
	//check if it is a type
	type = [self entityTypeWithName: name];
	if (type) { //previous column is type

	}else{

	}


	PajeEntityType *type;

	if ([self isContainerEntityType: type]){
		int count = [[self containedTypesForContainerType: type] count];
		//get also the containers instance
		NSEnumerator *en = enumeratorOfContainersTyped: type


	}else{
		return [[self allValuesForEntityType: type] count];
	}
*/
}


- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
	PajeEntityType *type;
	if ([browser selectedCell]){
		NSString *name = [[browser selectedCell] stringValue];
		type = [self entityTypeWithName: name];
	}else{
		type = [[self rootInstance] entityType];
	}

	NSArray *ar;
	if ([self isContainerEntityType: type]){
		ar = [self containedTypesForContainerType: type];
	}else{
		ar = [self allValuesForEntityType: type];
	}
	id obj = [ar objectAtIndex: row];
	if ([obj isKindOfClass: [PajeEntityType class]]){
		[cell setStringValue: [obj name]];
		[cell setLeaf: NO];
	}else{
		[cell setStringValue: obj];
		[cell setLeaf: YES];
	}
}

- (void) hierarchyChanged
{


//	window->HierarchyChanged();
//	[super hierarchyChanged];
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
	NSMutableSet *set = [NSMutableSet setWithArray:
		[super containedTypesForContainerType: containerType]];
	[set minusSet: hiddenEntityTypes];
	return [set allObjects];
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
