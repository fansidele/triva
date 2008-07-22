#include "TrivaFusion.h"
#include "FusionState.h"
#include "FusionLink.h"
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
		NSLog (@"type=%@", stateType);
		if ([stateType isKindOfClass: [PajeStateType class]]){
			//for now, only merge StateType 
			break;
		}
	}

//	aux = [[self containedTypesForContainerType:
//			[self entityTypeForEntity: container]]
//				objectEnumerator];
//	NSLog (@"fathers contained types:");
//	while ((stateType = [aux nextObject]) != nil) {
//		NSLog (@"type=%@", stateType);
//	}

//	return;

	mergedContainer = [FusionContainer containerWithType: containerType
				name: name
				container: container];
	
	en1 = [containers objectEnumerator];
	PajeContainer *containerAux;
	while ((containerAux = [en1 nextObject])){
		mergedContainer = [self mergeType: stateType
				ofContainer: mergedContainer
				withContainer: containerAux];
	}
	[super hierarchyChanged];
}

NSDate *maior (id x, id y, NSMutableSet *ps)
{
	NSDate *ret = [NSDate distantPast];
	NSMutableSet *aux = [NSMutableSet set];
	if (x != nil){
		[aux addObject: [x startTime]];
		[aux addObject: [x endTime]];
	}
	if (y != nil){
		[aux addObject: [y startTime]];
		[aux addObject: [y endTime]];
	}
	NSEnumerator *en = [aux objectEnumerator];
	id k;
	while ((k = [en nextObject])){
		if (![ps containsObject: k]){
			if ([ret compare: k] == NSOrderedAscending){
				ret = k;
			}
		}
	}
	[ps addObject: ret];
	return ret;
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

	id x;
	x = [mergedEnumerator nextObject];
	if (x == nil){
		id statev;
		FusionChunk *chunk;
		chunk = [[EntityChunk alloc] initWithEntityType: type
				container: merged];
		NSEnumerator *en = [[containerEnumerator allObjects] reverseObjectEnumerator];
		while ((statev = [en nextObject])){
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
		[merged setChunk: chunk];
	}else{
		id y = [containerEnumerator nextObject];
		NSDate *p1, *p2;
		NSMutableSet *ps = [NSMutableSet set];

		FusionChunk *chunk;
		chunk = [[EntityChunk alloc] initWithEntityType: type
				container: merged];
		p1 = maior (x, y, ps);
		do {
			p2 = maior (x, y, ps);
//			NSLog (@"(%@,%@) between (%@-%@)", 
//				[x name], [y name],
//				p2, p1);
			FusionState *s = [[FusionState alloc] initWithType: type
						name: @""
						container: mergedContainer];
			[s setStartTime: p2];
			[s setEndTime: p1];
			if ([chunk endTime] == nil){
				[chunk setEndTime: p1];
			}
			[chunk setStartTime: p2];
			if (x == nil){
				[s setName: [y name]];
			}else if (y == nil){
				[s setName: [x name]];
			}else{
				[s setName: [NSString stringWithFormat: @"%@-%@", [x name], [y name]]];
			}
			[chunk addEntity: s];
			p1 = p2;
			if (x != nil && 
			   ([p1 compare: [x startTime]] == NSOrderedAscending ||
			    [p1 compare: [x startTime]] == NSOrderedSame)){
				x = [mergedEnumerator nextObject];
			}

			if (y != nil && 
			   ([p1 compare: [y startTime]] == NSOrderedAscending ||
			    [p1 compare: [y startTime]] == NSOrderedSame)){
				y = [containerEnumerator nextObject];
			}
		}while (x != nil || y != nil);
		[merged setStartTime: [chunk startTime]];
		[merged setEndTime: [chunk endTime]];
		[chunk freeze];
		[merged setChunk: chunk];
	}
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
	}else if (container == [mergedContainer container]){
		NSLog (@"pai do cara é %@", [container name]);
	
	}else{
		return [super enumeratorOfEntitiesTyped: entityType
			inContainer: container
			fromTime: start
			toTime: end
			minDuration: minDuration];
	}
}

- (PajeContainer *) filterContainer: (PajeContainer *) container
{
	NSEnumerator *en = [containers objectEnumerator];
	id cont;
	while ((cont = [en nextObject])){
		if (cont == container){
			NSLog (@"cont = %@, container = %@ returning %@",
			[cont name], [container name], [mergedContainer name]);
			return mergedContainer;
		}
	}
	return container;
}

- (NSEnumerator *) filterLinksOfType: (PajeEntityType *)entityType
		inContainer:(PajeContainer *)container
		fromTime:(NSDate *)start
		toTime:(NSDate *)end
		minDuration:(double)minDuration
{
	if (![entityType isKindOf: [PajeLinkType class]]){
		return [super enumeratorOfCompleteEntitiesTyped: entityType
			inContainer: container
			fromTime: start
			toTime: end
			minDuration: minDuration];
	}
	NSMutableArray *ret = [NSMutableArray array];
	NSEnumerator *en;
	en = [super enumeratorOfCompleteEntitiesTyped: entityType
		inContainer: container
		fromTime: start
		toTime: end
		minDuration: minDuration];
	id link;
	while ((link = [en nextObject])){
		NSLog (@"link=%@ %@", [link name], [link class]);
		FusionLink *nlink = [[FusionLink alloc] initWithType: entityType
						name: [link name]
						container: container];
		[nlink setSourceContainer: [self filterContainer: [link sourceContainer]]];
		[nlink setDestContainer: [self filterContainer: [link destContainer]]];
		[nlink setStartTime: [link startTime]];
		[nlink setEndTime: [link endTime]];
		[ret addObject: nlink];
	}
	return [ret objectEnumerator];
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
	if (container == mergedContainer){
		return [mergedContainer enumeratorOfCompleteEntitiesTyped: entityType fromTime: start toTime: end];
	}else if (container == [mergedContainer container]){
		//substitute merged containers in links by containers
		return [self filterLinksOfType: entityType
			inContainer: container
			fromTime: start
			toTime: end
			minDuration: minDuration];
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

		//remove merged containers
		en = [containers objectEnumerator];
		id cont;
		while ((cont = [en nextObject])){
			[ar removeObject: cont];
		}
	
		//merge links ??
		//just when answering

		return [ar objectEnumerator];
	}else{
		return [super enumeratorOfContainersTyped: entityType
			inContainer: container];
	}
}

- (PajeContainer *)containerWithName:(NSString *)n
                                type:(PajeEntityType *)t
{
	if ([n isEqualToString: [mergedContainer name]]){
		return mergedContainer;
	}else{
		[super containerWithName: n type: t];
	}
}
@end
