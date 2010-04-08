#include "TimeInterval.h"

@implementation TimeInterval
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
		[NSBundle loadNibNamed: @"TimeInterval" owner: self];
	}
	[sliceView setFilter: self];
	selStart = 0;
	selEnd = 0;

	[frequencySlider setMinValue: 0.001];
	[frequencySlider setMaxValue: 4];

	timer = nil;
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
	double end = [timeSelectionEnd doubleValue];
	[self setTimeIntervalFrom: start to: end];
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

- (void) forwardSliderChanged: (id)sender
{
	[forwardLabel setDoubleValue: [forwardSlider doubleValue]];
}

- (void) frequencySliderChanged: (id)sender
{
	[frequencyLabel setDoubleValue: [frequencySlider doubleValue]];
}

- (void) timeLimitsChanged
{
	NSDate *start = [self startTime];
	NSDate *end = [self endTime];

	[traceStartTimeLabel setStringValue: [start description]];
	[traceEndTimeLabel setStringValue: [end description]];

	[startSlider setMinValue: [[start description] doubleValue]];
	[startSlider setMaxValue: [[end description] doubleValue]];
	[startSlider setDoubleValue: [[start description] doubleValue]];

	[sizeSlider setMinValue: [[start description] doubleValue]];
	[sizeSlider setMaxValue: [[end description] doubleValue]];
	[sizeSlider setDoubleValue: [[end description] doubleValue]];

	if (!selStart){
		selStart = [[start description] doubleValue];
	}
	if (!selEnd){
		selEnd = [[end description] doubleValue];
	}
	[self updateLabels];
}

- (void) updateLabels
{
	[timeSelectionStart setDoubleValue: selStart];
	[timeSelectionEnd setDoubleValue: selEnd];
	[startSlider setDoubleValue: selStart];

	[forwardSlider setMinValue: 0];
	[forwardSlider setMaxValue: selEnd-selStart];
	[forwardLabel setDoubleValue: [forwardSlider doubleValue]];

//	TODO
//	[sizeSlider setDoubleValue: end-start];

	[sliceView setNeedsDisplay: YES];
}

- (void) apply
{
	[super timeSelectionChanged];
}

// from the protocol 
- (NSDate *) selectionStartTime
{
	if (selStart){
		return [NSDate dateWithTimeIntervalSinceReferenceDate:selStart];
	}else{
		return [super selectionStartTime];
	}
}

- (NSDate *) selectionEndTime
{
	if (selEnd){
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
		if (start > traceEnd){
			start = end;
			[timer invalidate];
			timer = nil;
			[playButton setState: NSOffState];
		}
		end = traceEnd;
	}
	if (start > end){
		start = end;
	}

	[self setTimeIntervalFrom: start to: end];
	if (![updateOnChange state]){
		[self apply];
	}
}
@end