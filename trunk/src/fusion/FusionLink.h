#ifndef __FUSIONLINK_H
#define __FUSIONLINK_H
#include <Foundation/Foundation.h>
#include <General/PajeContainer.h>

@interface FusionLink : PajeEntity
{
	NSDate *startTime;
	NSDate *endTime;
	PajeContainer *sourceContainer;
	PajeContainer *destContainer;
}
- (NSDate *) startTime;
- (NSDate *) endTime;
- (void) setStartTime: (NSDate *) time;
- (void) setEndTime: (NSDate *) time;

- (void) setSourceContainer: (PajeContainer *) cont;
- (void) setDestContainer: (PajeContainer *) cont;
@end

#endif
