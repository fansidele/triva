#include "TrivaFusion.h"
#include "FusionState.h"
#include "FusionChunk.h"

@implementation TrivaFusion
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	return self;
}

- (void)setSelectedContainers:(NSSet *)cont
{
	if (containers != nil){
		[containers release];
	}
	containers = cont;
	[containers retain];
	[super setSelectedContainers: cont];
}

- (void) mergeSelectedContainers
{
	if (containers == nil){
		return;
	}

	/* check container's type and */
	/* search startTime, endTime */
	NSDate *startTime = nil, *endTime = nil;
	NSEnumerator *en1 = [containers objectEnumerator];
	id cont;
	NSMutableString *name = [NSMutableString string];
	while ((cont = [en1 nextObject])){
		static PajeEntityType *et = nil;
		if (et == nil){
			et = [self entityTypeForEntity: cont];
		}else{
			if (et != [self entityTypeForEntity: cont]){
				NSString *str;
				str = [NSString stringWithFormat:
					@"Selected containers "
					"of different types. Found "
					" types %@ and %@.",
					[et name],
					[[self entityTypeForEntity: cont]name]
					];
				[[NSException exceptionWithName:@"TrivaFusion"
					reason: str userInfo: nil] raise];
			}else{
				if (startTime == nil){
					startTime = [cont startTime];
				}
				if (endTime == nil){
					endTime = [cont endTime];
				}

				startTime = [[cont startTime] earlierDate: startTime];
				endTime = [[cont endTime] laterDate: endTime];
			}
		}
		[name appendString: [cont name]];
	}
	[name appendString: @"-MERGED"];
	en1 = [containers objectEnumerator];
	cont = [en1 nextObject];

	PajeContainer *container = [cont container];
	PajeContainerType *containerType = [self entityTypeForEntity: cont];

	/* search for State Type inside first container to be merged */
	NSEnumerator *aux;
	aux = [[self containedTypesForContainerType:
			[self entityTypeForEntity: cont]]
					objectEnumerator];

	while ((stateType = [aux nextObject]) != nil) {
		if ([stateType isKindOfClass: [PajeStateType class]]){
			//for now, only merge StateType 
			break;
		}
	}
	mergedContainer = [FusionContainer containerWithType: containerType
				name: name
				container: container];
	
	en1 = [containers objectEnumerator];
	PajeContainer *containerAux;
	while ((containerAux = [en1 nextObject])){
		mergedContainer = [self mergeType: stateType
				ofContainer: mergedContainer
				withContainer: containerAux];
		break;
	}
	[super hierarchyChanged];
}

- (FusionContainer *) mergeType: (PajeEntityType *) type
		ofContainer: (FusionContainer *) merged
			withContainer: (PajeContainer *) container
{
	NSEnumerator *mergedEnumerator;
	NSEnumerator *containerEnumerator;
	mergedEnumerator = [self enumeratorOfEntitiesTyped: type
		inContainer: merged
		fromTime: [self startTime]
		toTime: [self endTime]
		minDuration: 0];
	containerEnumerator = [self enumeratorOfEntitiesTyped: type
			inContainer: container
			fromTime: [self startTime]
			toTime: [self endTime]
			minDuration: 0];

	id statev;
	FusionChunk *chunk;
	chunk = [[EntityChunk alloc] initWithEntityType: type
			container: merged];
	while ((statev = [containerEnumerator nextObject])){
		FusionState *s = [[FusionState alloc] initWithType: type
					name: [statev name]
					container: mergedContainer];
		[s setStartTime: [statev startTime]];
		[s setEndTime: [statev endTime]];
		if ([chunk endTime] == nil){
			[chunk setEndTime: [s endTime]];
		}
		[chunk setStartTime: [s startTime]];
		[chunk addEntity: s];
	}
	[merged setStartTime: [chunk startTime]];
	[merged setEndTime: [chunk endTime]];
	[chunk freeze];
	[merged addChunk: chunk];
	return merged;
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
	if (container == mergedContainer){
		return [mergedContainer enumeratorOfEntitiesTyped: entityType
				fromTime: start toTime: end];
	}else{
		return [super enumeratorOfEntitiesTyped: entityType
			inContainer: container
			fromTime: start
			toTime: end
			minDuration: minDuration];
	}
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
	if (container == mergedContainer){
		return [mergedContainer enumeratorOfCompleteEntitiesTyped: entityType fromTime: start toTime: end];
	}else{
		return [super enumeratorOfCompleteEntitiesTyped: entityType
			inContainer: container
			fromTime: start
			toTime: end
			minDuration: minDuration];
	}
}

- (NSEnumerator *)enumeratorOfContainersTyped:(PajeEntityType *)entityType
                                  inContainer:(PajeContainer *)container
{
	if (entityType == [mergedContainer entityType]){
		NSEnumerator *en;
		en = [super enumeratorOfContainersTyped: entityType 
			inContainer: container];
		NSMutableArray *ar;
		ar = [NSMutableArray arrayWithArray: [en allObjects]];
		[ar addObject: mergedContainer];
		return [ar objectEnumerator];
	}else{
		return [super enumeratorOfContainersTyped: entityType
			inContainer: container];
	}
}
@end
