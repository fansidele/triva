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
#include "CompareController.h"

@implementation CompareController
- (id) init
{
  self = [super init];
  compareFilters = [[NSMutableArray alloc] init];
  if (self != nil){
    [NSBundle loadNibNamed: @"Compare" owner: self];
  }
  [window initializeWithDelegate: self];
  [markerTypeButton removeAllItems];
  [markerTypeButton setEnabled: NO];
  [view setController: self];
  return self;
}

- (void) dealloc
{
  [compareFilters release];
  [super dealloc];
}

- (void) addFilters: (NSArray*) filters
{
  [compareFilters addObjectsFromArray: filters];
}

- (void) timeLimitsChangedWithSender: (Compare*) c
{
  //the Compare filters that are on the Paje chain
  //call this method when the time limits of the traces change
  [view timeSelectionChangedWithSender: c];
  [view setNeedsDisplay: YES];
}

- (void) check
{
  //get filters
  id filter1 = [compareFilters objectAtIndex: 0];
  id filter2 = [compareFilters objectAtIndex: 1];

  //obtain type hierarchies
  NSMutableArray *typeHierarchies = [NSMutableArray array];
  [typeHierarchies addObject: [self typeHierarchy: filter1]];
  [typeHierarchies addObject: [self typeHierarchy: filter2]];

  //check if they are good to go
  if (![self checkTypeHierarchies: typeHierarchies]){
    //they do not match, raise exception
    [NSException raise:@"TrivaException"
                format:@"The type hierarchies of trace files do not match."];
  }

  //search for markers
  //TODO

  [view update];
}

- (NSArray*) filters
{
  return compareFilters;
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}


- (double) largestEndTime
{
  NSEnumerator *en = [compareFilters objectEnumerator];
  NSDate *largest = [NSDate distantPast];
  id filter;
  while ((filter = [en nextObject])){
    if ([largest compare: [filter endTime]] == NSOrderedAscending){
      largest = [filter endTime];
    }
    largest = [largest laterDate: [filter endTime]];
  }
  return [[largest description] doubleValue];
}

- (BOOL) startSynchronized
{
  if ([startSynchronized state] == NSOnState){
    return YES;
  }else{
    return NO;
  }
}

- (BOOL) endSynchronized
{
  if ([endSynchronized state] == NSOnState){
    return YES;
  }else{
    return NO;
  }
}

- (void) setStartTimeInterval: (double) start
                     ofFilter: (id) filter
{
  NSEnumerator *en = [compareFilters objectEnumerator];
  if ([self startSynchronized]){
    id f;
    while ((f = [en nextObject])){
      [f setSelectionStart: start];
    }
  }else{
    [filter setSelectionStart: start];
  }
}

- (void) setEndTimeInterval: (double) end
                   ofFilter: (id) filter
{
  NSEnumerator *en = [compareFilters objectEnumerator];
  if ([self endSynchronized]){
    id f;
    while ((f = [en nextObject])){
      [f setSelectionEnd: end];
    }
  }else{
    [filter setSelectionEnd: end];
  }
}
@end
