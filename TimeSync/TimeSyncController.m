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
#include "TimeSyncController.h"
#include <float.h>

@implementation TimeSyncController
- (id) init
{
  self = [super init];
  compareFilters = [[NSMutableArray alloc] init];
  if (self != nil){
    [NSBundle loadGSMarkupNamed: @"TimeSync" owner: self];
  }
  [window initializeWithDelegate: self];
  [window setAcceptsMouseMovedEvents: YES];
  [markerTypeButton removeAllItems];
  [markerTypeButton setEnabled: NO];
 
  [scrollview setRulersVisible: YES];
  [scrollview setHasHorizontalRuler: YES];
  [scrollview setHasVerticalRuler: NO];
  NSRulerView *horizRuler = [scrollview horizontalRulerView];
  [horizRuler setOriginOffset: 10];

  NSRect vrect = NSMakeRect(0,0,0,0);
  vrect.size = [NSScrollView frameSizeForContentSize: [scrollview contentSize]
                               hasHorizontalScroller: [scrollview hasHorizontalScroller]
                                 hasVerticalScroller: [scrollview hasVerticalScroller]
                                          borderType: [scrollview borderType]];
  view = [[CompareView alloc] initWithFrame: vrect];
  [view setController: self];
  [scrollview setDocumentView: view];


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

- (void) timeLimitsChangedWithSender: (TimeSync*) c
{
  //the TimeSync filters that are on the Paje chain
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
  //check if they are good to go
  if (![self checkTypeHierarchies: compareFilters]){
    //they do not match, raise exception
    [NSException raise:@"TrivaException"
                format:@"The type hierarchies of trace files do not match."];
  }

  //search for markers
  NSArray *markerTypes = [self markerTypes];
  if ([markerTypes count]){
    NSEnumerator *en = [markerTypes objectEnumerator];
    id type;
    while ((type = [en nextObject])){
      [markerTypeButton addItemWithTitle: [type description]];
    }
    [markerTypeButton setEnabled: YES];
  }

  [view update];

  //activate markers if there is one in the list
  if ([markerTypes count]){
    [view markerTypeChanged: self];
  }
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

- (void) timeSelectionChangedOfFilter: (TimeSync*) filter
{
  NSEnumerator *en = [compareFilters objectEnumerator];
  if ([self startSynchronized] || [self endSynchronized]){
    id f;
    while ((f = [en nextObject])){
      [f timeSelectionChanged];
    }
  }else{
    [filter timeSelectionChanged];
  }
}

- (void) setTimeIntervalStart: (double) start
                          end: (double) end
                     ofFilter: (id) filter
{
  if (![self startSynchronized] && ![self endSynchronized]){
    [filter setTimeIntervalFrom: start to: end];
    return;
  }

  NSEnumerator *en = [compareFilters objectEnumerator];
  id f;
  while ((f = [en nextObject])){
    double s = [[[f selectionStartTime] description] doubleValue];
    double e = [[[f selectionEndTime] description] doubleValue];

    double rs, re; //start and end that will be used
    if ([self startSynchronized]){
      rs = start;
    }else{
      rs = s;
    }
    if ([self endSynchronized]){
      re = end;
    }else{
      re = e;
    }
    [f setTimeIntervalFrom: rs to: re];
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
