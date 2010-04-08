#include "TimeInterval.h"
#include "SliceDraw.h"

wxString NSSTRINGtoWXSTRING (NSString *ns)
{
        if (ns == nil){
                return wxString();
        }
        return wxString::FromAscii ([ns cString]);
}

NSString *WXSTRINGtoNSSTRING (wxString wsa)
{
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return [NSString stringWithFormat:@"%s", sa];
}

std::string WXSTRINGtoSTDSTRING (wxString wsa)
{
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return std::string(sa);
}


static wxTimer timer;
TimeIntervalWindow *window;

@implementation TimeInterval
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	window = new TimeIntervalWindow ((wxWindow*)NULL);
	window->Show();
	window->setController ((id)self);
	window->getSliceDraw()->setController ((id)self);

	selectionStartTime = nil;
	selectionEndTime = nil;

	window->startSlider->SetRange (-INT_MAX, INT_MAX);
	window->sizeSlider->SetRange (-INT_MAX, INT_MAX);
	window->forwardSlider->SetRange (-INT_MAX, INT_MAX);
	window->frequencySlider->SetRange (-INT_MAX, INT_MAX);

	window->startSlider->SetValue (-INT_MAX); //min
	window->sizeSlider->SetValue (INT_MAX);  //max
	window->forwardSlider->SetValue(-INT_MAX);
	window->frequencySlider->SetValue(-INT_MAX);

	enable = NO;
	animationIsRunning = NO;
	frequency = 0.001;
	forward = 0;
	return self;
}

- (void) timeLimitsChanged
{
	if (!enable){
		selectionStartTime = [self startTime];
		selectionEndTime = [self endTime];
		[self updateLabels];
		enable = YES;
	}
}

- (double) traceTimeForSliderPosition: (int) position withSize: (double) size
{
	return ((position + (double)INT_MAX)/(2*(double)INT_MAX))*size;
}

- (int) sliderPositionForTraceTime: (double) time withSize: (double) size
{
	return -INT_MAX + time/size * 2*INT_MAX;
}

- (void) updateLabels
{
	//trace
	window->traceStartTime->SetLabel (NSSTRINGtoWXSTRING([[self startTime] description]));
	window->traceEndTime->SetLabel (NSSTRINGtoWXSTRING([[self endTime] description]));

	//slice
	window->timeSelectionStart->SetLabel (NSSTRINGtoWXSTRING([selectionStartTime description]));
	window->timeSelectionEnd->SetLabel (NSSTRINGtoWXSTRING([selectionEndTime description]));

	//animate
	window->forward->SetLabel (NSSTRINGtoWXSTRING([NSString stringWithFormat: @"%.2f", forward]));
	window->frequency->SetLabel (NSSTRINGtoWXSTRING([NSString stringWithFormat: @"%.3f", frequency]));
}

- (void) setTimeIntervalFrom: (double) start to: (double) end
{
	[selectionStartTime release];
	[selectionEndTime release];
	selectionStartTime = [NSDate dateWithTimeIntervalSinceReferenceDate:
					start];
	selectionEndTime = [NSDate dateWithTimeIntervalSinceReferenceDate:
					end];
	[self updateLabels];

}

/* from the protocol */
- (NSDate *) selectionStartTime
{
	if (selectionStartTime){
		return selectionStartTime;
	}else{
		return [super selectionStartTime];
	}
}

- (NSDate *) selectionEndTime
{
	if (selectionEndTime){
		return selectionEndTime;
	}else{
		return [super selectionEndTime];
	}
}

- (void) animate
{
	double traceEnd = [[[self endTime] description] doubleValue];

	double start = [[selectionStartTime description] doubleValue];
	double end = [[selectionEndTime description] doubleValue];
	start = start + forward;
	end = end + forward;

	if (end > traceEnd){
		if (start > traceEnd){
			start = end;
			[self pause];
		}
		end = traceEnd;
	}
	if (start > end){
		start = end;
	}

	[self setTimeIntervalFrom: start to: end];
	window->sliceDraw->Update();
	window->sliceDraw->Refresh();

	int position = [self sliderPositionForTraceTime: start
				withSize: traceEnd];
	window->startSlider->SetValue (position);

	[self apply];
}

/* callbacks from GUI */
- (void) animationSliderChanged
{
	//frequency is bounded [0.001, 4]
	//forward is bounded by the time slice

	double max = INT_MAX;
	double val = window->frequencySlider->GetValue();
	double porcentage = ((max + val)/(2 * max));
	frequency = 0.001 + (4 - 0.001) * porcentage; // [0.001,4]

	val = window->forwardSlider->GetValue();
	porcentage = ((max + val)/(2 * max));

	//time slice size is end-start
	double start = [[selectionStartTime description] doubleValue];
	double end = [[selectionEndTime description] doubleValue];
	forward = (end - start) * porcentage;
	[self updateLabels];
}


- (void) sliderChanged
{
	double traceEnd = [[[self endTime] description] doubleValue];

	double s, size;
	s = [self traceTimeForSliderPosition: window->startSlider->GetValue()
				withSize: traceEnd];
	size = [self traceTimeForSliderPosition: window->sizeSlider->GetValue()
				withSize: traceEnd];//THINK: why not traceEnd-s?

	double e = s+size;
	if (e > traceEnd){
		e = traceEnd;
	}

	[self setTimeIntervalFrom: s to: e];
	window->sliceDraw->Update();
	window->sliceDraw->Refresh();

	if (window->timeSliceCheckBox->IsChecked()){
		[self apply];
	}
}

- (void) apply
{
	[super timeSelectionChanged];
}

- (BOOL) play
{
	if (animationIsRunning){
		return NO;
	}
	[self apply];
	timer.SetOwner (window);
	timer.Start (frequency*1000, wxTIMER_CONTINUOUS);
	window->Connect (wxID_ANY, wxEVT_TIMER,
		wxTimerEventHandler(TimeIntervalWindow::animate));
	animationIsRunning = YES;
	return YES;
}

- (BOOL) pause
{
	if (animationIsRunning){
		timer.Stop();
		animationIsRunning = NO;
	}
	return YES;
}
@end
