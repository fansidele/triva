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
#include "General/FilteredEnumerator.h"

@implementation TypeFilter
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    [NSBundle loadNibNamed: @"TypeFilter" owner: self];
  }
  [self configureGUI];

  hiddenEntityTypes = [[NSMutableSet alloc] init];
  hiddenContainers = [[NSMutableSet alloc] init];
  hiddenEntityValues = [[NSMutableDictionary alloc] init];
  enableNotifications = YES;
  return self;
}

- (void) hierarchyChanged
{
  [outlineview reloadData];
  [outlineview expandItem:nil expandChildren:YES];
  [scrollview setNeedsDisplay: YES];
  [outlineview setNeedsDisplay: YES];

  NSString *tracefilePath = [[self rootInstance] name];
  NSString *tf = [[tracefilePath componentsSeparatedByString: @"/"] lastObject];
  [window setTitle: [NSString stringWithFormat: @"Triva - %@ - TypeFilter", tf]];
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

- (BOOL) isHiddenValue: (NSString *) value
         forEntityType: (PajeEntityType*)type
{
  NSSet *set = [hiddenEntityValues objectForKey: type];
  if (set){
    return [set containsObject: value];

  }else{
    return NO;
  }
}

- (BOOL) isHiddenContainer: (PajeContainer *) container
             forEntityType: (PajeEntityType*)type
{
  return [hiddenContainers containsObject: [container name]];
}

- (void) filterEntityType: (PajeEntityType *) type
                     show: (BOOL) show
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

- (void) filterContainer: (PajeContainer *) container
                    show: (BOOL) show
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

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}
@end
