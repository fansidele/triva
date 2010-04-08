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

