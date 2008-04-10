#include "FusionContainer.h"

@implementation FusionContainer
+ (FusionContainer *) containerWithType: (id) type
		name: (NSString *) n
		container: (PajeContainer *) container
{
	return [[[self alloc] initWithType:type
					name: n
				container: container] autorelease];
}

- (id)initWithType:(PajeEntityType *)type
              name:(NSString *)n
         container:(PajeContainer *)c
{
    self = [super initWithType:type
                          name:n
                     container:c];
    if (self) {
	mergedState = [[ChunkArray alloc] init];
	startTime = nil;
	endTime = nil;
    }
    return self;
}

- (void) dealloc
{
	[mergedState release];
	[super dealloc];
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)type
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
{
	return [mergedState enumeratorOfEntitiesFromTime: start
			toTime: end];
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)type
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
{
	return [mergedState enumeratorOfCompleteEntitiesFromTime: start
			untilTime: end];
}

- (void) setChunk: (EntityChunk *) chunk
{
	if (mergedState != nil){
		[mergedState release];
	}
	mergedState = [[ChunkArray alloc] init];
	[mergedState addChunk: chunk];
}

- (NSDate *) startTime
{
	return startTime;
}

- (NSDate *) endTime
{
	return endTime;
}

- (void) setStartTime: (NSDate *) time
{
	if (startTime != nil){
		[startTime release];
	}
	startTime = time;
	[startTime retain];
}

- (void) setEndTime: (NSDate *) time
{
	if (endTime != nil){
		[endTime release];
	}
	endTime = time;
	[endTime retain];
}
@end
