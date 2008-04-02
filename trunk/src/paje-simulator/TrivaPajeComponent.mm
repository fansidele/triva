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

	graph = [@"( ( PajeEventDecoder, \
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
    int i;
        [self startChunk:chunkNumber];
        i = -(int)[simulator eventCount];
        if ([reader hasMoreData]) {
            [reader readNextChunk];
        }
        [self endOfChunkLast:![reader hasMoreData]];
}

- (void)startChunk:(int)chunkNumber
{
//	NSLog (@"%s - chunkNumber:%d", __FUNCTION__, chunkNumber);
    [reader startChunk:chunkNumber];
    if ([reader hasMoreData] && (unsigned int)chunkNumber >= [chunkDates count]) {
        [chunkDates addObject:[simulator currentTime]];
        timeLimitsChanged = YES;
    }
}

- (void)endOfChunkLast:(BOOL)last
{
//	NSLog (@"%s - last:%d", __FUNCTION__, last);
    [reader endOfChunkLast:last];
    if (timeLimitsChanged) {
        [encapsulator timeLimitsChanged];
        timeLimitsChanged = NO;
    }
}

- (void)missingChunk:(int)chunkNumber
{
//	NSLog (@"%s - chunkNumber:%d", __FUNCTION__, chunkNumber);
    [self readChunk:chunkNumber];
}

- (void)readNextChunk:(id)sender
{
//	NSLog (@"%s - senderr:%@", __FUNCTION__, sender);
	[self readChunk:[chunkDates count]];
//	NSLog (@"%s - sender :%@ (AFTER)", __FUNCTION__, sender);
}

- (void)createComponentGraph
{
	[self addComponentSequences:[[self class] defaultComponentGraph]];
//	reader = [self componentWithName:@"FileReader"];
	reader = nil;
	simulator = [self componentWithName:@"PajeSimulator"];
	encapsulator = [self componentWithName:@"StorageController"];
}

- (void)chunkFault:(NSNotification *)notification
{
//	NSLog (@"%s", __FUNCTION__);
    int chunkNumber;

    chunkNumber = [[[notification userInfo]
                          objectForKey:@"ChunkNumber"] intValue];
    [self readChunk:chunkNumber];
}

/*
- (void)setInputFilename:(NSString *)name
{
    [reader setInputFilename:name];
}
*/

- (BOOL) setOutputFilter: (id) output
{
	id lastComponent;
	lastComponent = [self componentWithName: @"AggregatingFilter"];
	[self connectComponent: lastComponent toComponent: output];
	return YES;

}

- (BOOL) setInputFilter: (id<PajeReader>) input
{
	id firstComponent;
	firstComponent = [self componentWithName: @"PajeEventDecoder"];
	[self connectComponent: input toComponent: firstComponent];
	reader = input;
	return YES;
}
@end
