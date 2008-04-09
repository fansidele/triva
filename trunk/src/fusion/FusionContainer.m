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
	NSLog (@"%s mergedState = %@", __FUNCTION__, mergedState);
	NSLog (@"start=%@ end=%@", start, end);
	return [mergedState enumeratorOfEntitiesFromTime: start
			toTime: end];
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)type
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
{
	NSLog (@"%s mergedState = %@", __FUNCTION__, mergedState);
	return [mergedState enumeratorOfCompleteEntitiesFromTime: start
			untilTime: end];
}

- (void) addChunk: (EntityChunk *) chunk
{
	NSLog (@"adding chunk %@", chunk);
	[mergedState addChunk: chunk];
}
@end
