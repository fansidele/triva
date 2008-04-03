#include "TrivaPajeReader.h"

@implementation TrivaPajeReader
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
		integrator = [[IntegratorLib alloc] init];
		moreData = YES;	
		currentChunk = -1;
		dataChunk = [[NSMutableData alloc] init];
	}
	return self;
}

- (void)startChunk:(int)chunkNumber
{
	if (currentChunk == -1){
		currentChunk = chunkNumber;
	}else{
		int dif = chunkNumber - currentChunk;
		if (dif != 1){
			//problem, i don't know how to re-read
		}else{
			currentChunk = chunkNumber;
		}
	}

	// notify others that chunkNumber is starting 
	[super startChunk: chunkNumber];
}

- (void)endOfChunkLast:(BOOL)last
{
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

- (NSMutableData *) readDataFromDIMVisual
{
	NSMutableData *data = [NSMutableData data];

	NSMutableArray *events = [NSMutableArray array];
	int i;
	for (i = 0; i < 10; i++){
		NSMutableArray *a = [integrator convert];
		if (a != nil){
			[events addObjectsFromArray: a];
		}else{
			moreData = NO;
			NSLog (@"%s: End Of Data", __FUNCTION__);
			break;
		}
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
	if (![self hasMoreData]){
		return YES;
	}
	NSData *data = [self readDataFromDIMVisual];
	NSData *data2 = [[NSData alloc] initWithData: data];
	BOOL x = [super canEndChunkBefore:data2];
	[data2 release];
	if (x == YES) {
		[dataChunk appendData: data];
		return YES;
	}else{
		return NO;
	}
}

- (void) readNextChunk
{
	if (moreData == NO){
		if ([dataChunk length] != 0){
			[self outputEntity: dataChunk];
			[dataChunk release];
			dataChunk = [[NSMutableData alloc] init];
		}
		return;
	}

	NSMutableData *data = [self readDataFromDIMVisual];
	if ([dataChunk length] != 0){
		[dataChunk appendData: data];
		[self outputEntity: dataChunk];
		[dataChunk release];
		dataChunk = [[NSMutableData alloc] init];
	}else{
		[self outputEntity: data];
	}
	while (![self canEndChunk]) {
		;
	}
}

- (BOOL) hasMoreData
{
	if ([dataChunk length] != 0 || moreData){
		return YES;
	}else{
		return NO;
	}
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
