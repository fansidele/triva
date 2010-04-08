#include "SimGrid.h"
#include "SimGridDraw.h"

SimGridDraw *draw = NULL;

@implementation SimGrid
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	SimGridWindow *window = new SimGridWindow ((wxWindow*)NULL);
	window->Show();
	draw = window->getDraw();
	draw->setController ((id)self);
	return self;
}

- (BOOL) checkForSimGridHierarchy: (id) type level: (int) level
{
	id et;
	NSEnumerator *en;
	BOOL simulation, route, host;
	en = [[self containedTypesForContainerType: type] objectEnumerator];
	while ((et = [en nextObject]) != nil){
		if (level == 0){
			if ([[et name] isEqualToString: @"Simulation"]){
				simulation = [self checkForSimGridHierarchy: et
							level: level+1];
			}else if ([[et name] isEqualToString: @"Route"]){
				route = YES;
			}
		}else if (level == 1){
			if ([[et name] isEqualToString: @"host"]){
				host = YES;
			}
		}
	}
	if (level == 0){
		return simulation && route;
	}else if(level == 1){
		return host;
	}else{
		return YES;
	}
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
                                      minDuration:0.0];
            while ((ent = [en3 nextObject]) != nil) {
                NSLog(@"e%*.*s%@", level+2, level+2, "", [self descriptionForEntity:ent]);
            }
        }
    }
}


- (void) dumpTraceInTextualFormat
{
    [self printInstance:[self rootInstance] level:0];
}

- (NSArray *) findRoutesAt: (id) instance
{
	NSEnumerator *en;
	en = [[self containedTypesForContainerType:
		[self entityTypeForEntity: instance]] objectEnumerator];
	id et, ret = nil;
	while ((et = [en nextObject]) != nil && ret == nil){
		if (![self isContainerEntityType: et] &&
			[[et name] isEqualToString: @"Route"]){
			ret = [[self enumeratorOfEntitiesTyped: et
				inContainer: instance fromTime: [self startTime]
				toTime: [self endTime] minDuration: 0]
					allObjects];
		}else if ([self isContainerEntityType: et]){
			NSEnumerator *en2 = [self enumeratorOfContainersTyped: et
				inContainer:instance];
			PajeContainer *si;
			while ((si = [en2 nextObject]) != nil){
				ret = [self findRoutesAt: si];
				if (ret != nil) break;
			}
		}
	}
	return ret;
}

- (NSArray *) findHostsAt: (id) instance
{
	NSEnumerator *en;
	en = [[self containedTypesForContainerType:
		[self entityTypeForEntity: instance]] objectEnumerator];
	id et, ret = nil;
	while ((et = [en nextObject]) != nil && ret == nil){
		if ([self isContainerEntityType: et]){
			NSEnumerator *en2 = [self enumeratorOfContainersTyped: et
				inContainer:instance];
			PajeContainer *si;
			if ([[et name] isEqualToString: @"Host"]){
				ret = [en2 allObjects];
			}else{
				while ((si = [en2 nextObject]) != nil){
					ret = [self findHostsAt: si];
					if (ret != nil) break;
				}
			}
		}
	}
	return ret;
}



- (void) timeSelectionChanged
{
	draw->recreateResourcesGraph();
}
@end
