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
#include <float.h>

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

  [frequencySlider setMinValue: 0.001];
  [frequencySlider setMaxValue: 4];

  //checking user defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults boolForKey:@"ComparisonStartSynchronized"]){
    [startSynchronized setState: NSOnState];
  }else{
    [startSynchronized setState: NSOffState];
  }

  if ([defaults boolForKey:@"ComparisonEndSynchronized"]){
    [endSynchronized setState: NSOnState];
  }else{
    [endSynchronized setState: NSOffState];
  }
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
  
  //update the smaller slice
  double smaller = [self smallerSlice];
  [forwardSlider setMaxValue: smaller];
  [forwardLabel setDoubleValue: [forwardSlider doubleValue]];
}

- (void) check
{
  NSMutableArray *typeHierarchies = [NSMutableArray array];
  NSEnumerator *en = [compareFilters objectEnumerator];
  id filter = nil;
  while ((filter = [en nextObject])){
    [typeHierarchies addObject: [self typeHierarchy: filter]];
  }

  //check if they are good to go
  if (![self checkTypeHierarchies: typeHierarchies]){
    //they do not match, raise exception
    [NSException raise:@"TrivaException"
                format:@"The type hierarchies of trace files do not match."];
  }

  //search for markers
  NSArray *markerTypes = [self markerTypes];
  if ([markerTypes count]){
    en = [markerTypes objectEnumerator];
    id type;
    while ((type = [en nextObject])){
      [markerTypeButton addItemWithTitle: [type description]];
    }
    [markerTypeButton setEnabled: YES];
  }

  [view update];
}

- (NSString *) currentMarkerType
{
  return [markerTypeButton titleOfSelectedItem];
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

- (double) smallerSlice
{
  NSEnumerator *en = [compareFilters objectEnumerator];
  double smaller = FLT_MAX;
  id filter;
  while ((filter = [en nextObject])){
    double filStart = [[[filter selectionStartTime] description] doubleValue];
    double filEnd = [[[filter selectionEndTime] description] doubleValue];
    double dif = filEnd - filStart;
    if (dif < smaller){
      smaller = dif;
    }
  }
  return smaller;
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
    //controlling end time
    double endTime = [[[filter endTime] description] doubleValue];
    if (end > endTime) end = endTime;

    //go on
    id f;
    while ((f = [en nextObject])){
      [f setSelectionEnd: end];
    }
  }else{
    [filter setSelectionEnd: end];
  }
}

- (void) synchronizedChanged: (id)sender
{
  //save state on user defaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([startSynchronized state] == NSOnState){
    [defaults setObject: @"YES" forKey: @"ComparisonStartSynchronized"];
  }else{
    [defaults setObject: @"NO" forKey: @"ComparisonStartSynchronized"];
  }
  if ([endSynchronized state] == NSOnState){
    [defaults setObject: @"YES" forKey: @"ComparisonEndSynchronized"];
  }else{
    [defaults setObject: @"NO" forKey: @"ComparisonEndSynchronized"];
  }
}

- (void) forwardSliderChanged: (id)sender
{
  [forwardLabel setDoubleValue: [forwardSlider doubleValue]];
}

- (void) frequencySliderChanged: (id)sender
{
  [frequencyLabel setDoubleValue: [frequencySlider doubleValue]];
}

- (void) play: (id)sender
{
  if (timer){
    [timer invalidate];
    timer = nil;
  }else{
    SEL selector = @selector (animate);
    double interval = [frequencySlider doubleValue];
    timer = [NSTimer scheduledTimerWithTimeInterval: interval
      target: self
      selector: selector
      userInfo: nil
      repeats: YES];
  }
}

- (void) animate
{
  double forward = [forwardSlider doubleValue];

  NSEnumerator *en = [compareFilters objectEnumerator];
  id filter;
  while ((filter = [en nextObject])){
    double selStart = [[[filter selectionStartTime] description] doubleValue];
    double selEnd = [[[filter selectionEndTime] description] doubleValue];
    double traceEnd = [[[filter endTime] description] doubleValue];

    double start = selStart + forward;
    double end = selEnd + forward;

    //one of the filters reached 
    //stop animation condition
    if (end > traceEnd){
      [timer invalidate];
      timer = nil;
      [playButton setState: NSOffState];
      return;
    }
    [filter setTimeIntervalFrom: start to: end];
  }
}
@end
