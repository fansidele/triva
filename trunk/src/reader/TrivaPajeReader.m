#include "TrivaPajeReader.h"

@implementation TrivaPajeReader
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
		integrator = [[IntegratorLib alloc] init];
		moreData = YES;	
		currentChunk = 0;
		chunkInfo = [[NSMutableArray alloc] init];
		dataChunk = nil;
	}
	return self;
}

- (void)startChunk:(int)chunkNumber
{
//	NSLog (@"%s chunkNumber=%d", __FUNCTION__,chunkNumber);
	// go to chunkNumber, so next chunk read will be chunkNumber 
	if (chunkNumber != currentChunk) {
		currentChunk = chunkNumber;
	}

	// notify others that chunkNumber is starting 
	[super startChunk: chunkNumber];
}

- (void)endOfChunkLast:(BOOL)last
{
//	NSLog (@"%s - %d", __FUNCTION__, last);
	currentChunk++;
	// the currentChunk has ended 
	// ...
	//if (!last) {}
	
	// notify others about this
	[super endOfChunkLast: last];
}


- (void)raise:(NSString *)reason
{
    NSDebugLog(@"PajeFileReader: '%@' in file '%@', bytes read %lld",
                            reason, nil, 0);
    [[NSException exceptionWithName:@"PajeReadFileException"
                             reason:reason
                           userInfo:
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"DIMVIusalqwq", @"File Name",
            [NSNumber numberWithUnsignedLongLong:0],
                           @"BytesRead",
            nil]
        ] raise];
}

- (NSString *)inputFilename
{
    NSString *ret = @"DIMVisual-Input.trace";
//    NSLog (@"%s - returning (%@)", __FUNCTION__, ret);
    return ret;
}

- (NSString *)traceDescription
{
//	NSLog (@"%s", __FUNCTION__);
    return [self inputFilename];// stringByAbbreviatingWithTildeInPath];
}


- (void)setInputFilename:(NSString *)filename
{
	NSLog (@"%s - received filename=%@ (doing nothing about it)", __FUNCTION__, filename);
}

- (void)inputEntity:(id)entity
{
    [self raise:@"Configuration error:" " PajeFileReader should be first component"];
}

- (NSData *) readDataFromDIMVisual
{
	NSMutableData *data = [NSMutableData data];

	NSMutableArray *events = [NSMutableArray array];
	int i;
	events = [integrator convert];
	if (events == nil){
		moreData = NO;
		NSLog (@"%s: End Of Data", __FUNCTION__);
		return data;
	}

	static int flag = 0;
	if (!flag){
		[data appendData: [[headerCenter print] dataUsingEncoding: NSASCIIStringEncoding]];
		flag = 1;
	}
	for (i = 0; i < [events count]; i++){
		LibPajeEvent *ev = [events objectAtIndex: i];
		if ([headerCenter headerIsPresent: [ev header]] == NO){
			[headerCenter addHeader: [ev header]];
			int code = [headerCenter codeForHeader: [ev header]];
			[data appendData: [[headerCenter printHeaderWithCode: code] dataUsingEncoding: NSASCIIStringEncoding]];
		}
		[data appendData: [[ev printWithProvider: headerCenter] dataUsingEncoding: NSASCIIStringEncoding]];
	}
	return data;
}

- (BOOL)canEndChunk
{
	if (moreData == NO){
		return YES;
	}
	NSData *data = [self readDataFromDIMVisual];
	NSData *data2 = [[NSData alloc] initWithData: data];
	BOOL x = [super canEndChunkBefore:data2];
	[data2 release];
	if (x) {
		if (dataChunk == nil){
			dataChunk = [[NSMutableData alloc] init];
		}
		[dataChunk appendData: data];
		return YES;
	}else{
		return NO;
	}
}

- (void) readNextChunk
{
	if (moreData == NO){
		return;
	}
	int nextChunk = currentChunk +1;
	if (nextChunk < [chunkInfo count]) {
	}else{
		GSDebugAllocationActive(YES);
		NSMutableData *data = [self readDataFromDIMVisual];
		if (dataChunk == nil){
			dataChunk = [[NSMutableData alloc] init];
		}
		[dataChunk appendData: data];
		[self outputEntity: dataChunk];
		[dataChunk release];
		dataChunk = nil;
		while (![self canEndChunk]) {
			;
		}
	}


	if (moreData == NO){
		NSLog (@"%s End Of Data", __FUNCTION__);
	}
	return;
}

- (BOOL) hasMoreData
{
	return moreData;
}

/* other non-paje related stuff, but important for triva */
- (id) hierarchy
{
	return [integrator hierarchy];
}

- (NSArray *) dimvisualBundlesAvailable
{
	NSLog (@"%s", __FUNCTION__);
	return [integrator dimvisualBundlesAvailable];
}

- (BOOL) isDIMVisualBundleLoaded: (NSString *) name
{
	return [integrator isDIMVisualBundleLoaded: name];
}

- (BOOL) loadDIMVisualBundle: (NSString *) bundleName
{
	return [integrator loadDIMVisualBundle: bundleName];
}
- (NSDictionary *) getConfigurationOptionsFromDIMVisualBundle: (NSString *)name
{
	return [integrator getConfigurationOptionsFromDIMVisualBundle: name];
}

- (BOOL) setConfiguration: (NSDictionary *) conf forDIMVisualBundle: (NSString *) name
{
	BOOL ret = [integrator setConfiguration: conf forDIMVisualBundle: name];
	if (ret == YES){
//		headerCenter = [integrator pajeHeaderCenter];   
		headerCenter = [[PajeHeaderCenter alloc] initWithDefaultHeader];
		return YES;
	}else{
		return NO;
	}
}
@end
