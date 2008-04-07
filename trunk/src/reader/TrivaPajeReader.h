#ifndef __TRIVAPAJEREADER_H
#define __TRIVAPAJEREADER_H
#include <Foundation/Foundation.h>
#include <GenericEvent/GEvent.h> /* for the GEvent protocol */
#include <DIMVisual/Protocols.h> /* for the FileReader protocol */
#include <DIMVisual/IntegratorLib.h>
#include <General/PajeFilter.h>

@interface TrivaPajeReader  : PajeFilter <PajeReader>
{
	IntegratorLib *integrator;
	BOOL moreData; 
	PajeHeaderCenter *headerCenter;

	NSMutableData *dataChunk;

	unsigned counter;
	unsigned currentChunk;
	NSMutableArray *chunkInfo;
}
- (id)initWithController:(PajeTraceController *)c;

- (unsigned) getCounter;
- (void)setInputFilename:(NSString *)filename;
- (NSString *)inputFilename;

- (BOOL) hasMoreData;
- (void) readNextChunk;

- (void)startChunk:(int)chunkNumber;
- (void)endOfChunkLast:(BOOL)last;

- (void)raise:(NSString *)reason;

- (id) hierarchy;
- (NSArray *) dimvisualBundlesAvailable;
- (BOOL) isDIMVisualBundleLoaded: (NSString *) name;
- (BOOL) loadDIMVisualBundle: (NSString *) bundleName;
- (NSDictionary *) getConfigurationOptionsFromDIMVisualBundle: (NSString *)name;
- (BOOL) setConfiguration: (NSDictionary *) conf forDIMVisualBundle: (NSString *) name;
@end

#endif
