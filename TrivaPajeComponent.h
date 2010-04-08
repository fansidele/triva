#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <General/PSortedArray.h>

@interface TrivaPajeComponent : NSObject
{
	id reader;
	id simulator;
	id encapsulator;

	NSMutableDictionary *bundles;
	NSMutableDictionary *components;

	PSortedArray *chunkDates;
	BOOL timeLimitsChanged;

	NSMutableArray *parameters;
}

- (NSBundle *)bundleWithName:(NSString *)name;
- (NSBundle *)loadBundleNamed:(NSString*)name;
+ (NSArray *)defaultComponentGraph;
- (id)createComponentWithName:(NSString *)componentName
                 ofClassNamed:(NSString *)className;
- (void)connectComponent:(id)c1 toComponent:(id)c2;
- (id)componentWithName:(NSString *)name;
- (void)connectComponentNamed:(NSString *)n1
             toComponentNamed:(NSString *)n2;
- (void)addComponentSequence:(NSArray *)componentSequence;
- (void)addComponentSequences:(NSArray *)componentSequences;
- (void)createComponentGraph;
- (void)startChunk:(int)chunkNumber;
- (void)endOfChunkLast:(BOOL)last;
- (int)readNextChunk:(id)sender;
- (BOOL) hasMoreData;

- (void) setReaderWithName: (NSString *) readerName;

- (NSDate *) startTime; //starttime of the encapsulator
- (NSDate *) endTime; //endtime of the encapsulator

- (void)setSelectionStartTime:(NSDate *)from
                      endTime:(NSDate *)to;
- (void) addParameter: (NSString *) par;
- (NSString *) getParameterNumber: (int) index;
@end
