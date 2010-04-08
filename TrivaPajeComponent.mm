#include "TrivaPajeComponent.h"

@implementation TrivaPajeComponent
- (id) init
{
	self = [super init];
	components = [NSMutableDictionary dictionary];
	bundles = [NSMutableDictionary dictionary];
	[self createComponentGraph];

	chunkDates = [[NSClassFromString(@"PSortedArray") alloc]
                                initWithSelector:@selector(self)];

	NSNotificationCenter *notificationCenter;
	notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
		selector:@selector(chunkFault:)
		name:@"PajeChunkNotInMemoryNotification"
		object:nil];

	return self;
}

- (NSBundle *)loadTrivaBundleNamed:(NSString*)name
{
    NSString *bundleNameDev;
    NSString *bundleName;
    NSMutableArray *bundlePaths;
    NSEnumerator *pathEnumerator;
    NSString *path;
    NSString *bundlePath;
    NSBundle *bundle;

    bundleName = [@"Bundles" stringByAppendingPathComponent:@"Triva"];
    bundleName = [bundleName stringByAppendingPathComponent:name];
    bundleName = [bundleName stringByAppendingPathExtension:@"bundle"];

    bundleNameDev = [@"" stringByAppendingPathComponent: name];
    bundleNameDev = [bundleNameDev stringByAppendingPathComponent:name];
    bundleNameDev = [bundleNameDev stringByAppendingPathExtension:@"bundle"];

    /* try dev */
    NSFileManager *manager = [NSFileManager defaultManager];
    bundlePath = [manager currentDirectoryPath];
    bundlePath = [bundlePath stringByAppendingPathComponent:bundleNameDev];
    bundle = [NSBundle bundleWithPath:bundlePath];
    if ([bundle load]) {
        [bundles setObject:bundle forKey:name];
        NSLog (@"Warning, using DEV bundle(%@) at %@", name, bundlePath);
        return bundle;
    }

    bundlePaths = [[NSUserDefaults standardUserDefaults]
                                       arrayForKey:@"BundlePaths"];
    if (!bundlePaths) {
        bundlePaths = NSSearchPathForDirectoriesInDomains(
                                            NSAllLibrariesDirectory,
                                            NSAllDomainsMask, YES);
    }

    pathEnumerator = [bundlePaths objectEnumerator];
    while ((path = [pathEnumerator nextObject]) != nil) {
        bundlePath = [path stringByAppendingPathComponent:bundleName];
        bundle = [NSBundle bundleWithPath:bundlePath];
        if ([bundle load]) {
            [bundles setObject:bundle forKey:name];
            return bundle;
        }
    }
    [NSException raise:@"TrivaException" format:@"Bundle '%@' not found", name];
    return nil;
}

- (NSBundle *)bundleWithName:(NSString *)name
{
    NSBundle *bundle;

    bundle = [bundles objectForKey:name];
    if (bundle == nil) {
        if ([self loadBundleNamed:name] == nil){
		[self loadTrivaBundleNamed:name];
	}
        bundle = [bundles objectForKey:name];
    }
    return bundle;
}

- (NSBundle *)loadBundleNamed:(NSString*)name
{
    NSString *bundleName;
    NSArray *bundlePaths;
    NSEnumerator *pathEnumerator;
    NSString *path;
    NSString *bundlePath;
    NSBundle *bundle;

    bundleName = [@"Bundles" stringByAppendingPathComponent:@"Paje"];
    bundleName = [bundleName stringByAppendingPathComponent:name];
    bundleName = [bundleName stringByAppendingPathExtension:@"bundle"];

    bundlePaths = [[NSUserDefaults standardUserDefaults]
                                       arrayForKey:@"BundlePaths"];
    if (!bundlePaths) {
        bundlePaths = NSSearchPathForDirectoriesInDomains(
                                            NSAllLibrariesDirectory,
                                            NSAllDomainsMask, YES);
    }

    pathEnumerator = [bundlePaths objectEnumerator];
    while ((path = [pathEnumerator nextObject]) != nil) {
        bundlePath = [path stringByAppendingPathComponent:bundleName];
        bundle = [NSBundle bundleWithPath:bundlePath];
        if ([bundle load]) {
            [bundles setObject:bundle forKey:name];
            return bundle;
        }
    }
    //[NSException raise:@"PajeException" format:@"Bundle '%@' not found", name];
    return nil;
}



+ (NSArray *)defaultComponentGraph
{
    NSArray *graph;

	graph = [@"(  \
		( FileReader, \
		   PajeEventDecoder, \
                   PajeSimulator, \
                   StorageController, \
                   TimeInterval, \
		   TimeSliceAggregation, \
		   SquarifiedTreemap \
		), \
		(  TimeInterval, \
		   MemoryAccess \
		) )" propertyList];
	graph = [@"(  \
		( FileReader, \
		   PajeEventDecoder, \
                   PajeSimulator, \
                   StorageController, \
                   TimeInterval, \
		   MemoryAccess \
		) )" propertyList];
	graph = [@"(  \
		( FileReader, \
		   PajeEventDecoder, \
                   PajeSimulator, \
                   StorageController, \
		   TimeInterval, \
                   OgreView \
		) )" propertyList];
	graph = [@"(  \
		( FileReader, \
		   PajeEventDecoder, \
                   PajeSimulator, \
                   StorageController, \
                   SimGrid \
		) )" propertyList];


    return graph;
}

- (id)createComponentWithName:(NSString *)componentName
                 ofClassNamed:(NSString *)className
{
    Class componentClass;
    id component;

    componentClass = NSClassFromString(className);
    if (componentClass == Nil) {
        NSBundle *bundle;
        bundle = [self bundleWithName:className];
	componentClass = NSClassFromString(className);
	if (componentClass == nil){
		componentClass = [bundle principalClass];
	}
    }
    component = [componentClass componentWithController: (id)self];
    if (component != nil) {
        [components setObject:component forKey:componentName];
    }
    return component;
}


- (void)connectComponent:(id)c1 toComponent:(id)c2
{
    [c1 setOutputComponent:c2];
    [c2 setInputComponent:c1];
}


- (id)componentWithName:(NSString *)name
{
    id component;

    component = [components objectForKey:name];
    if (component == nil) {
        NSString *className;
        if ([[NSScanner scannerWithString:name]
                scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                           intoString:&className]) {
            component = [self createComponentWithName:name
                                         ofClassNamed:className];
        }
    }
    return component;
}


- (void)connectComponentNamed:(NSString *)n1
             toComponentNamed:(NSString *)n2
{
    id c1;
    id c2;

    c1 = [self componentWithName:n1];
    c2 = [self componentWithName:n2];
    [self connectComponent:c1 toComponent:c2];
}


- (void)addComponentSequence:(NSArray *)componentSequence
{
    int index;
    int count;

    count = [componentSequence count];
    for (index = 1; index < count; index++) {
        NSString *componentName1;
        NSString *componentName2;
        componentName1 = [componentSequence objectAtIndex:index-1];
        componentName2 = [componentSequence objectAtIndex:index];
        [self connectComponentNamed:componentName1
                   toComponentNamed:componentName2];
    }
}


- (void)addComponentSequences:(NSArray *)componentSequences
{
    int index;
    int count;

    count = [componentSequences count];
    for (index = 0; index < count; index++) {
        NSArray *componentSequence;
        componentSequence = [componentSequences objectAtIndex:index];
        [self addComponentSequence:componentSequence];
    }
}

- (void)readChunk:(int)chunkNumber
{
	[reader readNextChunk];
}

- (void)startChunk:(int)chunkNumber
{
    [reader startChunk:chunkNumber];
    if ([reader hasMoreData] && (unsigned int)chunkNumber >= [chunkDates count]) {
        [chunkDates addObject:[simulator currentTime]];
        timeLimitsChanged = YES;
    }
}

- (void)endOfChunkLast:(BOOL)last
{
    [reader endOfChunkLast:last];
    if (timeLimitsChanged) {
        [encapsulator timeLimitsChanged];
        timeLimitsChanged = NO;
    }
}

- (void)missingChunk:(int)chunkNumber
{
	NSString *str;
	str = [NSString stringWithFormat:
		@"%@: %s received by TrivaPajeComponent.", self, __FUNCTION__];
	[[NSException exceptionWithName: @"Triva" 
				reason: str
				userInfo: nil] raise];
//    [self readChunk:chunkNumber];
}

#define CHUNK_SIZE (10*1024*1024)

- (int)readNextChunk:(id)sender
{
	static BOOL chunkStarted = NO;
	if (!chunkStarted){
		[self startChunk: [chunkDates count]];
		chunkStarted = YES;
	}

	[self readChunk: -1 /* method ignores this number */];

	if (![reader hasMoreData] && chunkStarted){
		[self endOfChunkLast: ![reader hasMoreData]];
		chunkStarted = NO;
	}

	if ([reader hasMoreData]){
		return 1;
	}else{
		return 0;
	}
}

- (void)createComponentGraph
{
	[self addComponentSequences:[[self class] defaultComponentGraph]];
//	reader = [self componentWithName:@"TrivaPajeReader"];
	simulator = [self componentWithName:@"PajeSimulator"];
	encapsulator = [self componentWithName:@"StorageController"];
}

- (void)chunkFault:(NSNotification *)notification
{
    int chunkNumber;

    chunkNumber = [[[notification userInfo]
                          objectForKey:@"ChunkNumber"] intValue];
    [self readChunk:chunkNumber];
}

- (NSDate *) startTime
{
	return [encapsulator startTime];
}

- (NSDate *) endTime
{
	return [encapsulator endTime];
}

- (void) setReaderWithName: (NSString *) readerName
{
	reader = [self componentWithName: readerName];
}

- (BOOL) hasMoreData
{
        return [reader hasMoreData];
}

- (void)setSelectionStartTime:(NSDate *)from
                      endTime:(NSDate *)to
{
    [encapsulator setSelectionStartTime:from
                                  endTime:to];
}
@end