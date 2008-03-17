#include "TrivaPajeReader.h"

static NSFileHandle *file;

@implementation TrivaPajeReader
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
		integrator = [[IntegratorLib alloc] init];
		moreData = YES;	
		file = [NSFileHandle fileHandleForWritingAtPath: @"/tmp/toto.trace"];
		NSLog (@"file = %@", file);
	}
	return self;
}

- (void)startChunk:(int)chunkNumber
{
//	NSLog (@"%s - received chunkNumber=%d (doing nothing about it)", __FUNCTION__, chunkNumber);
}

- (void)endOfChunkLast:(BOOL)last
{
//	NSLog (@"%s - received last=%d (doing nothing about it)", __FUNCTION__, last);
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
    NSLog (@"%s - returning (%@)", __FUNCTION__, ret);
    return ret;
}

- (void)setInputFilename:(NSString *)filename
{
//	NSLog (@"%s - received filename=%@ (doing nothing about it)", __FUNCTION__, filename);
}

- (void)inputEntity:(id)entity
{
    [self raise:@"Configuration error:" " PajeFileReader should be first component"];
}

- (BOOL)canEndChunk
{
	NSLog (@"%s - returning YES", __FUNCTION__);
	return YES;
}


- (void) readNextChunk
{
	NSMutableArray *chunk = [[NSMutableArray alloc] init];
	int i;
	for (i = 0; i < 10; i++){
		NSMutableArray *a = [integrator convert];
		if (a != nil){
			[chunk addObjectsFromArray: a];
		}else{
			moreData = NO;
			break;
		}
	}

	NSMutableData *data = [NSMutableData data];

	int flag2 = 0;
	static int flag = 0;
	if (!flag){
//		NSLog (@"%@", [headerCenter print]);
		[data appendData: [[headerCenter print] dataUsingEncoding: NSASCIIStringEncoding]];
		flag = 1;
		flag2 = 1;
	}
	for (i = 0; i < [chunk count]; i++){
		LibPajeEvent *ev = [chunk objectAtIndex: i];
//		NSLog (@"ev = %@", ev);
		if ([headerCenter headerIsPresent: [ev header]] == NO){
			[headerCenter addHeader: [ev header]];
			int code = [headerCenter codeForHeader: [ev header]];
			[data appendData: [[headerCenter printHeaderWithCode: code] dataUsingEncoding: NSASCIIStringEncoding]];
		}
//		NSLog (@"%@ %@", [ev class], [ev printWithProvider: headerCenter]);
		[data appendData: [[ev printWithProvider: headerCenter] dataUsingEncoding: NSASCIIStringEncoding]];
		flag2 = 1;
	}
	if (flag2){
		[file writeData: data];
		[self outputEntity: data];
	}

	[chunk release];
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
