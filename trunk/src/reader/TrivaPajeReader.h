#ifndef __TRIVAPAJEREADER_H
#define __TRIVAPAJEREADER_H
#include <Foundation/Foundation.h>
#include <GenericEvent/GEvent.h> /* for the GEvent protocol */
#include <DIMVisual/Protocols.h> /* for the FileReader protocol */
#include <DIMVisual/IntegratorLib.h>
#include <General/PajeFilter.h>

@interface TrivaPajeReader  : PajeFilter
{
	IntegratorLib *integrator;
	BOOL moreData; 
	PajeHeaderCenter *headerCenter;

	NSMutableData *dataChunk;

	unsigned currentChunk;
	NSMutableArray *chunkInfo;
}
- (id)initWithController:(PajeTraceController *)c;

- (void)setInputFilename:(NSString *)filename;
- (NSString *)inputFilename;

- (BOOL) hasMoreData;
- (void) readNextChunk;

- (void)startChunk:(int)chunkNumber;
- (void)endOfChunkLast:(BOOL)last;

- (void)raise:(NSString *)reason;
@end

#endif
