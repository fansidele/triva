#ifndef __FUSIONSTATE_H
#define __FUSIONSTATE_H
#include <Foundation/Foundation.h>
#include <General/PajeContainer.h>

@interface FusionState : PajeEntity
{
	NSDate *startTime;
	NSDate *endTime;
}
- (NSDate *) startTime;
- (NSDate *) endTime;
- (void) setStartTime: (NSDate *) time;
- (void) setEndTime: (NSDate *) time;
@end

#endif
