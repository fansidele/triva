#include "TimeInterval.h"

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
	window->setSlidersRange (-INT_MAX, INT_MAX);

	selectionStartTime = nil;
	selectionEndTime = nil;

	enable = NO;
	return self;
}

- (void) timeLimitsChanged
{
	if (!enable){
		selectionStartTime = [self startTime];
		selectionEndTime = [self endTime];

		NSString *trstart = [NSString stringWithFormat: @"%f",
			[[self startTime] timeIntervalSinceReferenceDate]];
		NSString *trend = [NSString stringWithFormat: @"%f",
			[[self endTime] timeIntervalSinceReferenceDate]];

		window->setTraceStartTime (NSSTRINGtoWXSTRING(trstart));
		window->setTraceEndTime (NSSTRINGtoWXSTRING(trend));
		window->setSelectionStartTime (NSSTRINGtoWXSTRING(trstart));
		window->setSelectionEndTime (NSSTRINGtoWXSTRING(trend));
		window->Enable();
		enable = YES;
	}else{
		NSString *trstart = [NSString stringWithFormat: @"%f",
			[[self startTime] timeIntervalSinceReferenceDate]];
		NSString *trend = [NSString stringWithFormat: @"%f",
			[[self endTime] timeIntervalSinceReferenceDate]];

		window->setTraceStartTime (NSSTRINGtoWXSTRING(trstart));
		window->setTraceEndTime (NSSTRINGtoWXSTRING(trend));
	}
}

- (void) setTimeIntervalFrom: (int) start to: (int) end
{
	double traceEnd = [[[self endTime] description] doubleValue];
	double startPorcentage = (start + (double)INT_MAX)/(2*(double)INT_MAX);
	double endPorcentage = (end + (double)INT_MAX)/(2*(double)INT_MAX);

	[selectionStartTime release];
	[selectionEndTime release];
	selectionStartTime = [NSDate dateWithTimeIntervalSinceReferenceDate:
				startPorcentage*traceEnd];
	selectionEndTime = [NSDate dateWithTimeIntervalSinceReferenceDate:
				endPorcentage*traceEnd];
	[super timeSelectionChanged];
}

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

- (BOOL) forwardSelectionTime: (double) seconds
{	
	BOOL startstop = YES, endstop = YES;
	if ([[self endTime] compare: selectionStartTime] ==
		     NSOrderedDescending){
	        id old = selectionStartTime;
		selectionStartTime=[selectionStartTime addTimeInterval:seconds];
	        [old release];
		if ([[self endTime] compare: selectionStartTime] ==
				 NSOrderedAscending){
			[selectionStartTime release];
			selectionStartTime = [self endTime];
		}else{
			startstop = NO;
		}
	}
	if ([[self endTime] compare: selectionEndTime] == NSOrderedDescending){
	        id old = selectionEndTime;
		selectionEndTime = [selectionEndTime addTimeInterval: seconds];
		[old release];
		if ([[self endTime] compare: selectionEndTime] ==
			   NSOrderedAscending){
			[selectionEndTime release];
			selectionEndTime = [self endTime];
		}else{
			endstop = NO;
		}
	}
	[super timeSelectionChanged];
	return startstop && endstop;
}
@end
