#include "PajeOgreFilter.h"

@implementation PajeOgreFilter
- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)limitsChangedForEntityType:(PajeEntityType *)entityType
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)colorChangedForEntityType:(PajeEntityType *)entityType
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)orderChangedForContainerType:(PajeEntityType *)containerType;
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)timeSelectionChanged
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)containerSelectionChanged
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
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
                                      minDuration:0];
            while ((ent = [en3 nextObject]) != nil) {
                NSLog(@"e%*.*s%@", level+2, level+2, "", [self descriptionForEntity:ent]);
            }
        }
    }
}

- (void)printAll
{
    [self printInstance:[self rootInstance] level:0];
}

- (void)hierarchyChanged
{



  //      NSLog (@"##oi");
//    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
//        NSLog (@"antes");
  //  [self printAll];
    //    NSLog (@"depois");
//	NSLog (@"################ FIM @@@@@@@@@@@@@@");
}


- (void) setViewController: (ProtoView *) c
{
	viewController = c;
	[viewController retain];
}

- (void) dealloc
{
	[viewController release];
	[super dealloc];
}
@end
