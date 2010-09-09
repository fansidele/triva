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
#include "DifferenceController.h"

@implementation DifferenceController
- (id)initWithController:(id)c
{
  self = [super initWithController: c];
  [NSBundle loadNibNamed: @"Difference" owner: self];
  interceptFilters = [[NSMutableArray alloc] init];
  [window initializeWithDelegate: self];
  return self;
}

- (void) dealloc
{
  [interceptFilters release];
  [super dealloc];
}

- (void) addFilters: (NSArray *) filters
{
  [interceptFilters addObjectsFromArray: filters];
  if ([interceptFilters count]){
    //responder is the first filter
    inputComponent = [interceptFilters objectAtIndex: 0];
  }else{
    inputComponent = nil;
  }
}

- (void) timeLimitsChangedWithSender: (id) sender
{
  [self updateGUI];
}

- (void) timeSelectionChangedWithSender: (id) sender
{
  //update merged tree
  //A release current merged tree
  [mergedTree release];
  mergedTree = nil;
  NSEnumerator *en = [interceptFilters objectEnumerator];
  id intercept = [en nextObject];
  //B use first time slice tree as base
  mergedTree = [[TimeSliceDifTree alloc]initWithTree:[intercept timeSliceTree]];
  while ((intercept = [en nextObject])){
    if (configuredOperation == Subtract){
      [mergedTree subtractTree: [intercept timeSliceTree]];
    }else if (configuredOperation == Ratio){
      [mergedTree ratioTree: [intercept timeSliceTree]];
    }else{
      [mergedTree subtractTree: [intercept timeSliceTree]];
    }
  }
  //C aggregate?
//  [mergedTree doAggregation];
//  [mergedTree testTreeWithLevel: 0];
  [super timeSelectionChanged];
}

- (void) hierarchyChangedWithSender: (id) sender
{
  [self updateGUI];
}

//
// TrivaFilter protocol
//
- (TimeSliceTree*) timeSliceTree
{
  return mergedTree;
}


//
// Intercepted Filter Commands
//
- (NSString *)traceDescription
{
  return @"Merged Trace";
}

/*
- (void)hideEntityType:(PajeEntityType *)entityType
{
}

- (void)hideSelectedContainers
{
}

- (void)setSelectedContainers:(NSSet *)containers
{
}

- (void)setOrder:(NSArray *)containers
ofContainersTyped:(PajeEntityType *)containerType
     inContainer:(PajeContainer *)container
{
}

- (void)setSelectionStartTime:(NSDate *)from
                      endTime:(NSDate *)to
{
}

- (void)setColor:(NSColor *)color
        forValue:(id)value
    ofEntityType:(PajeEntityType *)entityType
{
}

- (void)setColor:(NSColor *)color
   forEntityType:(PajeEntityType *)entityType
{
}

- (void)setColor:(NSColor *)color
       forEntity:(id<PajeEntity>)entity;
{
}

- (void)verifyStartTime:(NSDate *)start
                endTime:(NSDate *)end
{
}

//
// Intercepted Inspecting an entity
//
- (void)inspectEntity:(id<PajeEntity>)entity
{
}


//
// Intercepted Acessing Entities
- (NSDate *)startTime
{
  return nil;
}

- (NSDate *)endTime
{
  return nil;
}

- (PajeContainer *)rootInstance
{
  return nil;
}

- (NSDate *)selectionStartTime
{
  return nil;
}

- (NSDate *)selectionEndTime
{
  return nil;
}

- (NSSet *)selectedContainers
{
  return nil;
}

- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType
{
  return nil;
}

- (PajeContainerType *)containerTypeForType:(PajeEntityType *)entityType
{
  return nil;
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
  return nil;
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)entityType
                                        inContainer:(PajeContainer *)container
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
                                        minDuration:(double)minDuration
{
  return nil;
}

- (NSEnumerator *)enumeratorOfContainersTyped:(PajeEntityType *)entityType
                                  inContainer:(PajeContainer *)container
{
  return nil;
}

- (NSArray *)allValuesForEntityType:(PajeEntityType *)entityType
{
  return nil;
}

- (NSString *)descriptionForEntityType:(PajeEntityType *)entityType
{
  return nil;
}

- (double)minValueForEntityType:(PajeEntityType *)entityType
{
  return 0;
}

- (double)maxValueForEntityType:(PajeEntityType *)entityType
{
  return 0;
}

- (double)minValueForEntityType:(PajeEntityType *)entityType
                    inContainer:(PajeContainer *)container
{
  return 0;
}

- (double)maxValueForEntityType:(PajeEntityType *)entityType
                    inContainer:(PajeContainer *)container
{
  return 0;
}

- (BOOL)isHiddenEntityType:(PajeEntityType *)entityType
{
  return 0;
}

- (PajeDrawingType)drawingTypeForEntityType:(PajeEntityType *)entityType
{
  return 0;
}

- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType
{
  return nil;
}

- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType
                                name:(NSString *)name
{
  return nil;
}

- (id)valueOfFieldNamed:(NSString *)fieldName
          forEntityType:(PajeEntityType *)entityType
{
  return nil;
}

- (NSColor *)colorForValue:(id)value
              ofEntityType:(PajeEntityType *)entityType
{
  return nil;
}

- (NSColor *)colorForEntityType:(PajeEntityType *)entityType
{
  return nil;
}

//
// Intercepted Getting info from entity
//

- (NSArray *)fieldNamesForEntity:(id<PajeEntity>)entity
{
  return nil;
}


- (id)valueOfFieldNamed:(NSString *)fieldName
              forEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (PajeContainer *)containerForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (PajeEntityType *)entityTypeForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (PajeContainer *)sourceContainerForEntity:(id<PajeLink>)entity
{
  return nil;
}

- (PajeEntityType *)sourceEntityTypeForEntity:(id<PajeLink>)entity
{
  return nil;
}

- (PajeContainer *)destContainerForEntity:(id<PajeLink>)entity
{
  return nil;
}

- (PajeEntityType *)destEntityTypeForEntity:(id<PajeLink>)entity
{
  return nil;
}

- (NSArray *)relatedEntitiesForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (NSColor *)colorForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (NSDate *)startTimeForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (NSDate *)endTimeForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (NSDate *)timeForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (double)durationForEntity:(id<PajeEntity>)entity
{
  return 0;
}

- (PajeDrawingType)drawingTypeForEntity:(id<PajeEntity>)entity
{
  return 0;
}

- (id)valueForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (double)doubleValueForEntity:(id<PajeEntity>)entity // for variables
{
  return 0;
}

- (double)minValueForEntity:(id<PajeEntity>)entity // for variables
{
  return 0;
}

- (double)maxValueForEntity:(id<PajeEntity>)entity // for variables
{
  return 0;
}

- (NSString *)descriptionForEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (int)imbricationLevelForEntity:(id<PajeEntity>)entity
{
  return 0;
}

- (BOOL)isAggregateEntity:(id<PajeEntity>)entity
{
  return 0;
}

- (unsigned)subCountForEntity:(id<PajeEntity>)entity
{
  return 0;
}

- (NSColor *)subColorAtIndex:(unsigned)index
                   forEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (id)subValueAtIndex:(unsigned)index
            forEntity:(id<PajeEntity>)entity
{
  return nil;
}

- (double)subDurationAtIndex:(unsigned)index
                   forEntity:(id<PajeEntity>)entity
{
  return 0;
}

- (unsigned)subCountAtIndex:(unsigned)index
                  forEntity:(id<PajeEntity>)entity
{
  return 0;
}

- (BOOL)canHighlightEntity:(id<PajeEntity>)entity
{
  return 0;
}

- (BOOL)isSelectedEntity:(id<PajeEntity>)entity
{
  return 0;
}



//
// Intercepted AuxiliaryMethods
//
- (PajeEntityType *)rootEntityType
{
  return nil;
}

- (NSArray *)allEntityTypes
{
  return nil;
}

- (BOOL)isContainerEntityType:(PajeEntityType *)entityType
{
  return 0;
}

- (PajeEntityType *)entityTypeWithName:(NSString *)n
{
  return nil;
}

- (PajeContainer *)containerWithName:(NSString *)n
                                type:(PajeEntityType *)t
{
  return nil;
}

- (NSString *)nameForContainer:(PajeContainer *)container
{
  return nil;
}
*/

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}

- (void) updateGUI
{
  id filter;
  NSEnumerator *en = [interceptFilters objectEnumerator];
  while ((filter = [en nextObject])){
  }
  if ([interceptFilters count] >= 1){
    [traceA setStringValue:
       [[[[interceptFilters objectAtIndex: 0] traceDescription]
            pathComponents] lastObject]];
  }
  if ([interceptFilters count] >= 2){
    [traceB setStringValue:
       [[[[interceptFilters objectAtIndex: 1] traceDescription]
            pathComponents] lastObject]];
  }
  [numberOfTraceFiles setIntValue: [interceptFilters count]];

  [operation removeAllItems];
  [operation addItemWithTitle: SUBTRACT_OPERATION];
  [operation addItemWithTitle: RATIO_OPERATION];
  [operation selectItemAtIndex: 0];
  [self operationChanged: self];
}

- (void) operationChanged: (id)sender
{
  NSString *selected = [operation titleOfSelectedItem];
  if ([selected isEqualToString: SUBTRACT_OPERATION]){
    configuredOperation = Subtract;  
  }else if ([selected isEqualToString: RATIO_OPERATION]){
    configuredOperation = Ratio; 
  }else{
    configuredOperation = Subtract;  
  }

  //trigger changes
  [self timeSelectionChangedWithSender: self];
}
@end
