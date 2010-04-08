#include <Foundation/Foundation.h>
#import <DIMVisual/IntegratorLib.h>
#import <GenericEvent/GEvent.h>
#include <General/PajeFilter.h>

@interface HCMReader : PajeFilter 
{
	NSMutableArray *buffer; /* of NSData* */
	NSConditionLock *bufferLock; /* lock for buffer */
	IntegratorLib *integrator;
	PajeHeaderCenter *headerCenter;
	NSFileHandle *outFile;
	NSArray *aggregatorNames;/* of (NSString *)  */
	NSString *clientId;
}
- (BOOL) sendToPaje: (NSData *) data;
- (void) waitForDataFromHCM: (id) object;
- (BOOL)applyConfiguration: (NSDictionary *) conf;
@end
