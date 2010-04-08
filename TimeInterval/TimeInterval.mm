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

		float start = [[self startTime] timeIntervalSinceReferenceDate];
		start *= TRIVA_TI;
		float end = [[self endTime] timeIntervalSinceReferenceDate];
		end *= TRIVA_TI;
		window->setSlidersRange ((int)start, (int)end);
	
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
	[selectionStartTime release];
	selectionStartTime = [NSDate dateWithTimeIntervalSinceReferenceDate:
				(double)start/TRIVA_TI];
	[selectionEndTime release];
	selectionEndTime = [NSDate dateWithTimeIntervalSinceReferenceDate:
				(double)end/TRIVA_TI];
	[super timeSelectionChanged];
}

- (NSDate *) startTime
{
	if (selectionStartTime){
		return selectionStartTime;
	}else{
		return [super startTime];
	}
}

- (NSDate *) endTime
{
	if (selectionEndTime){
		return selectionEndTime;
	}else{
		return [super endTime];
	}

}
@end
