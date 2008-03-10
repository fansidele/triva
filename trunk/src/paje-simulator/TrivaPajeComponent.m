#include "TrivaPajeComponent.h"
#include "draw/TrivaPajeFilter.h"

@implementation TrivaPajeComponent
- (id) init
{
	self = [super init];
	components = [NSMutableDictionary dictionary];
	bundles = [NSMutableDictionary dictionary];
	[self createComponentGraph];
	return self;
}

- (NSBundle *)bundleWithName:(NSString *)name
{
    NSBundle *bundle;

    bundle = [bundles objectForKey:name];
    if (bundle == nil) {
        [self loadBundleNamed:name];
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
    [NSException raise:@"PajeException" format:@"Bundle '%@' not found", name];
    return nil;
}



+ (NSArray *)defaultComponentGraph
{
    NSArray *graph;

	graph = [@"( ( FileReader, \
                   PajeEventDecoder, \
                   PajeSimulator, \
                   StorageController, \
                   AggregatingFilter \
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
    component = [componentClass componentWithController:self];
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
    int i;
    NSDate *start, *end, *e2;
    double t, t2;
    NSAutoreleasePool *pool;

    pool = [NSAutoreleasePool new];
    start = [NSDate date];

//    NS_DURING
        [self startChunk:chunkNumber];
        i = -(int)[simulator eventCount];
        if ([reader hasMoreData]) {
      //      NSDebugMLLog(@"tim", @"will read chunk starting at %@",
    //                                [simulator currentTime]);
//            NSLog(@"will read chunk starting at %@",
  //                                  [simulator currentTime]);
            [reader readNextChunk];
        }
        [self endOfChunkLast:![reader hasMoreData]];
/*

    NS_HANDLER
		NSLog (@" exception = %@"
			"reason = %@"
			"userInfo = %@", [localException name],
					[localException reason],
					[localException userInfo]);
	
        if (NSRunAlertPanel([localException name], @"%@\n%@",
                            @"Continue", @"Abort", nil,
                            [localException reason],
                            [localException userInfo]
                            //[[[localException userInfo] objectEnumerator] 
                            //allObjects]
                            ) != NSAlertDefaultReturn)
//            [[NSApplication sharedApplication] terminate:self];
    NS_ENDHANDLER
*/

    end = [[NSDate date] retain];
    t = [end timeIntervalSinceDate:start];
    i += [simulator eventCount];

    [pool release];

    e2 = [NSDate date];
    t2 = [e2 timeIntervalSinceDate:end];
    [end release];
    //NSLog(@"%@: %d events in %f seconds = %f e/s; rel=%f", [reader inputFilename], i, t, i/t, t2);
}

- (void)startChunk:(int)chunkNumber
{
    [reader startChunk:chunkNumber];
    if ([reader hasMoreData] && chunkNumber >= [chunkDates count]) {
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
    [self readChunk:chunkNumber];
}



- (void)readNextChunk:(id)sender
{
	[self readChunk:[chunkDates count]];
}

- (void)createComponentGraph
{
	[self addComponentSequences:[[self class] defaultComponentGraph]];
	reader = [self componentWithName:@"FileReader"];
	simulator = [self componentWithName:@"PajeSimulator"];
	encapsulator = [self componentWithName:@"StorageController"];
}


- (void)setInputFilename:(NSString *)name
{
    [reader setInputFilename:name];
}

- (BOOL) setOutputFilter: (PajeFilter *) output
{
	id lastComponent = [self componentWithName: @"AggregatingFilter"];
//	TrivaPajeFilter *tpf = [TrivaPajeFilter componentWithController:self];
	[self connectComponent: lastComponent toComponent: output];
	return YES;

}

- (BOOL) setInputFilter: (PajeFilter *) input
{
	return YES;
}

@end
