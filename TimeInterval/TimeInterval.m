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
#include "TimeInterval.h"

@implementation TimeInterval
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    [NSBundle loadGSMarkupNamed: @"TimeInterval" owner: self];
  }
  [sliceView setFilter: self];
  [sliceWindowView setFilter: self];
  selStart = -1;
  selEnd = -1;

  [frequencySlider setMinValue: 0.001];
  [frequencySlider setMaxValue: 4];

  timer = nil;

  hideWindow = NO;

  [window initializeWithDelegate: self];
  return self;
}

- (void) setTimeIntervalFrom: (double) start to: (double) end
{
  selStart = start;
  selEnd = end;

  [self updateLabels];

  if ([updateOnChange state]){
    [self apply];
  }
}

- (void) apply: (id)sender
{
  double start = [timeSelectionStart doubleValue];
  double size = [timeSelectionSize doubleValue];
  [self setTimeIntervalFrom: start to: start+size];
  if (![updateOnChange state]){
    [self apply];
  }
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

- (void) sliceSliderChanged: (id)sender
{
  double traceEnd = [[[self endTime] description] doubleValue];
  double start = [startSlider doubleValue];
  double size = [sizeSlider doubleValue];
  double end = start+size;
  if (end > traceEnd){
    end = traceEnd;
  }
  [self setTimeIntervalFrom: start to: end];
}

- (void) forwardLabelChanged: (id) sender
{
  double value = [forwardLabel doubleValue];
  if (value < [forwardSlider minValue]){
    value = [forwardSlider minValue];
  }
  if (value > [forwardSlider maxValue]){
    value = [forwardSlider maxValue];
  }
  [forwardSlider setDoubleValue: value];
  [forwardLabel setDoubleValue: value];
}

- (void) forwardSliderChanged: (id)sender
{
  [forwardLabel setDoubleValue: [forwardSlider doubleValue]];
}

- (void) frequencyLabelChanged: (id) sender
{
  double value = [frequencyLabel doubleValue];
  if (value < [frequencySlider minValue]){
    value = [frequencySlider minValue];
  }
  if (value > [frequencySlider maxValue]){
    value = [frequencySlider maxValue];
  }
  [frequencySlider setDoubleValue: value];
  [frequencyLabel setDoubleValue: value];
}

- (void) frequencySliderChanged: (id)sender
{
  [frequencyLabel setDoubleValue: [frequencySlider doubleValue]];
}

- (void) timeSelectionChanged
{
  [self timeLimitsChanged];
}

- (void) timeLimitsChanged
{
  NSDate *start = [self startTime];
  NSDate *end = [self endTime];

  if ([forwardOnChange state]){
    //save current size
    double sliceSize = selEnd - selStart;
    //update selStart and selEnd from the end of the trace
    [self setTimeIntervalFrom: [[end description] doubleValue] - sliceSize
                           to: [[end description] doubleValue]];
    //trigger the apply action
    [self apply];
  }

  [traceStartTimeLabel setStringValue: [start description]];
  [traceEndTimeLabel setStringValue: [end description]];

  [startSlider setMinValue: [[start description] doubleValue]];
  [startSlider setMaxValue: [[end description] doubleValue]];
  [startSlider setDoubleValue: [[start description] doubleValue]];

  [sizeSlider setMinValue: [[start description] doubleValue]];
  [sizeSlider setMaxValue: [[end description] doubleValue]];
  [sizeSlider setDoubleValue: [[end description] doubleValue]];

  if (selStart < 0 && selEnd < 0){
    [self setTimeIntervalFrom: [[start description] doubleValue]
                           to: [[end description] doubleValue]];
    [self apply];
  }
  [self updateLabels];
}

- (void) updateLabels
{
  [timeSelectionStart setDoubleValue: selStart];
  [timeSelectionSize setDoubleValue: selEnd-selStart];
  [startSlider setDoubleValue: selStart];
  [sizeSlider setDoubleValue: selEnd-selStart];

  [forwardSlider setMinValue: 0];
  [forwardSlider setMaxValue: selEnd-selStart];
  [forwardLabel setDoubleValue: [forwardSlider doubleValue]];

//  TODO
//  [sizeSlider setDoubleValue: end-start];
  [self updateViews];
}

- (void) apply
{
  [super timeSelectionChanged];
}

// from the protocol 
- (NSDate *) selectionStartTime
{
  if (selStart >= 0){
    return [NSDate dateWithTimeIntervalSinceReferenceDate:selStart];
  }else{
    return [super selectionStartTime];
  }
}

- (NSDate *) selectionEndTime
{
  if (selEnd >= 0){
    return [NSDate dateWithTimeIntervalSinceReferenceDate: selEnd];
  }else{
    return [super selectionEndTime];
  }
}

- (void) animate
{
  double forward = [forwardSlider doubleValue];

  double traceEnd = [[[self endTime] description] doubleValue];

  double start = selStart;
  double end = selEnd;
  start = start + forward;
  end = end + forward;

  if (end > traceEnd){
    end = traceEnd;
  }

  //stop-animation condition
  if (end >= traceEnd){
    start = end;
    [timer invalidate];
    timer = nil;
    [playButton setState: NSOffState];
    return;
  }

  [self setTimeIntervalFrom: start to: end];
  if (![updateOnChange state]){
    [self apply];
  }
}

- (void)windowDidMove:(NSNotification *)win
{
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}

- (void) updateViews
{
  [sliceView setNeedsDisplay: YES];
  [sliceWindowView setNeedsDisplay: YES];
}

- (void) switchSliceWindowVisibility
{
  if ([sliceWindow isVisible]){
    [sliceWindow orderOut: nil];
  }else{
    [sliceWindow makeKeyAndOrderFront:nil];
  }
}

+ (NSDictionary *) defaultOptions
{
  NSBundle *bundle;
  bundle = [NSBundle bundleForClass: NSClassFromString(@"TimeInterval")];
  NSString *file = [bundle pathForResource: @"TimeInterval" ofType: @"plist"];
  return [NSDictionary dictionaryWithContentsOfFile: file];
}

- (void) setConfiguration: (TrivaConfiguration *) conf
{
  //extract my configuration and put in myOptions dictionary
  NSDictionary *myOptions = [conf configuredOptionsForClass: [self class]];

  //configure myself using the configuration in myOptions
  NSEnumerator *en = [myOptions keyEnumerator];
  NSString *key;
  double s = [[[self startTime] description] doubleValue];
  double e = [[[self endTime] description] doubleValue];
  BOOL apply = NO;
  BOOL animate = NO;
  while ((key = [en nextObject])){
    NSString *value = [myOptions objectForKey: key];
    if (0){
    }else if([key isEqualToString: @"ti_hide"]){
      hideWindow = YES;
    }else if([key isEqualToString: @"ti_update"]){
      [updateOnChange setState: YES];
    }else if([key isEqualToString: @"ti_start"]){
      s = [value doubleValue];
    }else if([key isEqualToString: @"ti_size"]){
      e = s + [value doubleValue];
    }else if([key isEqualToString: @"ti_apply"]){
      apply = YES;
    }else if([key isEqualToString: @"ti_forward"]){
      [forwardLabel setStringValue: value];
      [self forwardLabelChanged: self];
    }else if([key isEqualToString: @"ti_frequency"]){
      [frequencyLabel setStringValue: value];
      [self frequencyLabelChanged: self];
    }else if([key isEqualToString: @"ti_animate"]){
      animate = YES;
    }
  }
  [self setTimeIntervalFrom: s to: e];
  if (apply){
    [self apply: self];
  }
  if (animate){
    [playButton performClick: self];
    [self play: self];
  }
}

- (void) show
{
  if (!hideWindow){
    [window orderFront: self];
  }
}
@end
