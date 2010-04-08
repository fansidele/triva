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
#include "MemoryAccess.h"
#include "MAWindow.h"
#include <float.h>

MADraw *draw = NULL;

@implementation MemoryAccess
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	MAWindow *window = new MAWindow ((wxWindow*)NULL);
	window->Show();
	draw = window->getMADraw();
	draw->setController ((id)self);
	return self;
}

- (void) defineMemorySize: (MALayout *) la
{
	PajeEntityType *cpu = [self entityTypeWithName: @"CPU"];
	PajeEntityType *thread = [self entityTypeWithName: @"THREAD"];
	NSEnumerator *en = [self enumeratorOfContainersTyped: cpu
				inContainer: [self rootInstance]];

	NSMutableArray *values = [NSMutableArray array];
	id cpuEnt;
	while ((cpuEnt = [en nextObject])){
		NSEnumerator *en2 = [self enumeratorOfContainersTyped: thread
					inContainer: cpuEnt];
		id threadEnt;
		while ((threadEnt = [en2 nextObject])){
			PajeEntityType *et=[self entityTypeWithName: @"ACCESS"];
			NSEnumerator *en3 = [self enumeratorOfEntitiesTyped: et
					inContainer:  threadEnt
					fromTime: [self startTime]
					toTime: [self endTime]
					minDuration: 0.1];
			id ent;
			while ((ent = [en3 nextObject])){
				NSMutableString *val = [NSMutableString
stringWithString:[self valueOfFieldNamed: @"VirtualMemory" forEntity: ent]];
				double x = atof ([val cString]);
				[values addObject:
					[NSNumber numberWithDouble: x]];
			}
		}
	}
	//NSLog (@"values count %d", [values count]);
	[values sortUsingSelector: @selector(compare:)];
	NSEnumerator *en5 = [values objectEnumerator];
	id nu = [en5 nextObject];
	double c = [nu doubleValue], iant = [nu doubleValue];
	int count = 0;
	NSMutableArray *memoryWindow = [NSMutableArray array];
	while ((nu = [en5 nextObject])){
		double x = [nu doubleValue];
		if ((x-c) > (x*.3)){
			NSMutableDictionary *dict;
			dict = [NSMutableDictionary dictionary];
			[dict setObject: [NSNumber numberWithDouble: iant]
				forKey: @"start"];
			[dict setObject: [NSNumber numberWithDouble: c]
				forKey: @"end"];
			[dict setObject: [NSNumber numberWithInt: count]
				forKey: @"count"];
			[dict setObject: [NSNumber numberWithDouble: c-iant]
				forKey: @"dif"];
			//NSLog (@"%@", dict);
			[memoryWindow addObject: dict];
			iant = x;
			count = 0;
		}
		c = x;
		count++;
	}
	[la setMemoryWindow: memoryWindow];
}

- (void) findCPUandThreadsFor: (MALayout *) la
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	PajeEntityType *cpu = [self entityTypeWithName: @"CPU"];
	PajeEntityType *thread = [self entityTypeWithName: @"THREAD"];
	NSEnumerator *en = [self enumeratorOfContainersTyped: cpu
				inContainer: [self rootInstance]];
	id cpuEnt;
	while ((cpuEnt = [en nextObject])){
		[ret setObject: [[self enumeratorOfContainersTyped: thread
					inContainer: cpuEnt] allObjects]
			forKey: cpuEnt];
	}
	[la setCPUandThreadContainer: ret];
}

- (void) findMemoryFor: (MALayout *) la
{
	PajeEntityType *memory = [self entityTypeWithName: @"MEMORY"];
	NSEnumerator *en = [self enumeratorOfContainersTyped: memory
				inContainer: [self rootInstance]];
	id ent;
	while ((ent = [en nextObject])){
		if ([[ent name] isEqualToString: @"MEMORY-SIMICS"]){
			[la setMemoryContainer: ent];
			break;
		}
	}
}

- (void) timeSelectionChanged
{
	id root = [self rootInstance];
	if (current){
		[current release];
	}
	current = [[MALayout alloc] init];
	[self findCPUandThreadsFor: current];
	[self findMemoryFor: current];
	[self defineMemorySize: current];
	draw->Refresh();
}

- (MALayout *) layoutWithWidth: (int) width andHeight: (int) height
{
	[current defineLayoutWithWidth: width andHeight: height];
	return current;
}

- (void)printInstance:(id)instance level:(int)level
{
    NSLog(@"i%*.*s%@", level, level, "", [self descriptionForEntity:instance]);
    PajeEntityType *et;
    NSEnumerator *en;
    en = [[self containedTypesForContainerType:[self entityTypeForEntity:instance]] objectEnumerator];
    while ((et = [en nextObject]) != nil) {
        NSLog(@"t%*.*s%@", level+1, level+1, "", [self descriptionForEntityType:et]);
        if ([self isContainerEntityType:et]) {
            NSEnumerator *en2;
            PajeContainer *sub;
            en2 = [self enumeratorOfContainersTyped:et inContainer:instance];
            while ((sub = [en2 nextObject]) != nil) {
                [self printInstance:sub level:level+2];
            }
        } else {
            NSEnumerator *en3;
            PajeEntity *ent;
            en3 = [self enumeratorOfEntitiesTyped:et
                                      inContainer:instance
                                         fromTime:[self startTime]
                                           toTime:[self endTime]
                                      minDuration:0.01];
            while ((ent = [en3 nextObject]) != nil) {
                NSLog(@"e%*.*s%@", level+2, level+2, "", [self descriptionForEntity:ent]);
            }
        }
    }
}

@end
