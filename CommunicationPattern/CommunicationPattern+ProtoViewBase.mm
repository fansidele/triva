#include "CommunicationPattern.h"

@implementation CommunicationPattern (ProtoViewBase)
- (BOOL) applicationGraphWithAlgorithm: (NSString *) algo
{
	if (applicationGraphPosition == nil){
		applicationGraphPosition = [Position positionWithAlgorithm:@"graphviz"];
	}
	[applicationGraphPosition setSubAlgorithm: algo];

	[self hierarchyChanged];
	return YES;
}

// for application graph
- (NSMutableDictionary *) dictionaryForApplicationGraph: (id) entity
{
	if (entity == nil){
		return nil;
	}

        NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *me = [[NSMutableDictionary alloc] init];

        NSEnumerator *en = [[self containedTypesForContainerType:[self entityTypeForEntity:entity]] objectEnumerator];
        PajeEntityType *et;
        while ((et = [en nextObject]) != nil) {
                if ([self isContainerEntityType:et]) {
                        NSEnumerator *en2;
                        PajeContainer *sub;
                        en2 = [self enumeratorOfContainersTyped:et inContainer:entity];
                        while ((sub = [en2 nextObject]) != nil) {
                                NSMutableDictionary *d;
				d = [self dictionaryForApplicationGraph: sub];
                                [me addEntriesFromDictionary: d];
                        }
                }
        }
        [ret setObject: me forKey: [entity name]];
        [me release];
        [ret autorelease];
        return ret;
}

- (void) recalculateApplicationGraphWithApplicationData
{
	id instance = [self rootInstance];
	[applicationGraphPosition newHierarchyOrganization: 
			[self dictionaryForApplicationGraph: instance]];

        NSEnumerator *en = [[self containedTypesForContainerType:[self entityTypeForEntity:instance]] objectEnumerator];
        PajeEntityType *et;
        while ((et = [en nextObject]) != nil) {
                if ([et isKindOfClass: [PajeLinkType class]]){
                        NSEnumerator *en4;
                        en4 = [self enumeratorOfEntitiesTyped: et
                        inContainer: instance
                        fromTime:[self startTime]
                        toTime:[self endTime]
                        minDuration: 1/pointsPerSecond];
                        PajeEntity *ent;
                        while ((ent = [en4 nextObject]) != nil) {
                                NSString *sn = [[ent sourceContainer] name];
                                NSString *dn = [[ent destContainer] name];
                                [applicationGraphPosition 
					addLinkBetweenNode: sn andNode: dn];

                        }

                }
        }
	//applicationGraphPosition contains PositionGraphviz
	[applicationGraphPosition refresh];
}

- (BOOL) mustDrawContainer: (id) container
{
	BOOL answer = NO;

	if (container == [self rootInstance]){
		return answer;
	}

	NSEnumerator *en = [[self containedTypesForContainerType:
		[self entityTypeForEntity: container]] objectEnumerator];

	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([et isKindOfClass: [PajeLinkType class]]){
			answer = YES;
		}else if ([et isKindOfClass: [PajeStateType class]]){
			answer = YES;
		}
	}	
	return answer;
}
@end
