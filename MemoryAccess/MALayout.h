#ifndef __MALayout__h
#define __MALayout__h

#include <Foundation/Foundation.h>
#include <General/PajeContainer.h>

@interface MARect : NSObject
{
        float width;
        float height;
        float x;
        float y;
}
- (float) width;
- (float) height;
- (float) x;
- (float) y;
- (void) setWidth: (float) w;
- (void) setHeight: (float) h;
- (void) setX: (float) xis;
- (void) setY: (float) ipslon;
@end


@interface MALayout : NSObject
{
	NSDictionary *cpuThreadContainer; //cpuid -> array of threadid
	PajeContainer *memoryContainer;

	NSMutableDictionary *memoryLayout;
	NSMutableDictionary *cpuThreadLayout;

//	double smallestMemoryAddress;
//	double highestMemoryAddress;

	NSArray *memoryWindow;
}
- (void) setCPUandThreadContainer: (NSDictionary *) cputhread;
- (void) setMemoryContainer: (PajeContainer *) mem;
- (void) defineLayoutWithWidth: (int) width andHeight: (int) height;
- (NSDictionary *) memoryLayout;
- (NSDictionary *) cpuThreadLayout;
- (NSDictionary *) layout;
//- (void) setSmallestMemoryAddress: (double) s;
//- (void) setHighestMemoryAddress: (double) s;
//- (double) smallestMemoryAddress;
//- (double) highestMemoryAddress;
- (void) setMemoryWindow: (NSArray *) mem;
- (NSArray *) memoryWindow;
- (NSDictionary *) findMemoryWindowForValue: (double) val;
@end

#endif

