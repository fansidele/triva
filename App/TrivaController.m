/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "TrivaController.h"
#include "TrivaCommand.h"

@implementation TrivaController
+ (id) controllerWithConfiguration: (TrivaConfiguration *) configuration
{
  TrivaController *triva = nil;
  //configuring triva
  if ([configuration visualizationComponent] == TrivaComparison){
    triva = [[TrivaComparisonController alloc] initWithConfiguration: configuration];
  }else if ([configuration visualizationComponent] == TrivaMerge){
    triva = [[TrivaMergeController alloc] initWithConfiguration: configuration];
  }else{
    if ([configuration visualizationComponent] == TrivaSquarifiedTreemap) {
      triva = [[TrivaTreemapController alloc] initWithConfiguration: configuration];
    }else if ([configuration visualizationComponent] == TrivaGraphView){
      triva = [[TrivaGraphController alloc] initWithConfiguration: configuration];
    }else if ([configuration visualizationComponent] == TrivaLinkView){
      triva = [[TrivaLinkController alloc] initWithConfiguration: configuration];
    }else if ([configuration visualizationComponent] == TrivaHierarchy) {
      triva = [[TrivaDotController alloc] initWithConfiguration: configuration];
    }else if ([configuration visualizationComponent] == TrivaStat) {
      triva = [[TrivaStatController alloc] initWithConfiguration: configuration];
    }else if ([configuration visualizationComponent] == TrivaCheck) {
      triva = [[TrivaCheckController alloc] initWithConfiguration: configuration];
    }else if ([configuration visualizationComponent] == TrivaList) {
      triva = [[TrivaListController alloc] initWithConfiguration: configuration];
    }else if ([configuration visualizationComponent] == TrivaInstances) {
      triva = [[TrivaInstanceController alloc] initWithConfiguration: configuration];
    }else{
      NSException *exception = [NSException exceptionWithName: @"TrivaException"
                     reason: @"No visualization option activated" userInfo: nil];
      [exception raise];
    }
  }
  return triva;
}

- (void) dealloc
{
  [server release];
  [super dealloc];
}

- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super init];
  components = [NSMutableDictionary dictionary];
  bundles = [NSMutableDictionary dictionary];
  if ([configuration serverMode]){
    int serverPort = [configuration serverPort];
    server = [[TrivaServerSocket alloc] initWithPort: serverPort];
    [NSThread detachNewThreadSelector: @selector(runServer:)
                             toTarget: server
                           withObject: self];
  }else{
    server = nil;
  }
  return self;
}

- (void) updateWithConfiguration: (TrivaConfiguration *) configuration
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NS_DURING
  NSEnumerator *en = [components objectEnumerator];
  id component;
  while ((component = [en nextObject])){
    if ([component isKindOfClass: [TrivaFilter class]]){
      [component setConfiguration: configuration];
    }
  }
NS_HANDLER
  NSLog (@"Exception on configuring components.");
  NSLog (@"Info: %@", [localException userInfo]);
  NSLog (@"Name: %@", [localException name]);
  NSLog (@"Reason: %@", [localException reason]);
  NSLog (@"Configuration provided: %@", [configuration configuredOptions]);
  if (![configuration ignore]){
    exit(1);
  }
NS_ENDHANDLER
  [pool release];
}

- (void) initializeWithConfiguration: (TrivaConfiguration *) configuration
{
NS_DURING
  NSArray *files = [configuration inputFiles];
  NSLog (@"Tracefile (%@). Reading.... please wait\n", files);
  //reading only the first file by default (subclasses
  //should override this if necessary)
  reader = [self componentWithName:@"FileReader" fromDictionary: components];
  [reader setInputFilename: [files objectAtIndex: 0]];
  [self readAllTracefileFrom: reader];
  encapsulator = [self componentWithName:@"StorageController" fromDictionary: components];
  [encapsulator timeLimitsChanged];
  [encapsulator setSelectionStartTime: [encapsulator startTime]
                              endTime: [encapsulator endTime]];
NS_HANDLER
  NSLog (@"Exception on reading.");
  NSLog (@"Info: %@", [localException userInfo]);
  NSLog (@"Name: %@", [localException name]);
  NSLog (@"Reason: %@", [localException reason]);
  NSLog (@"Configuration provided: %@", [configuration configuredOptions]);
  exit(1);
NS_ENDHANDLER

  NSEnumerator *en;
  id component;

  //configuring components
  [self updateWithConfiguration: configuration];

  //open component windows
  en = [components objectEnumerator];
  while ((component = [en nextObject])){
    if ([component isKindOfClass: [TrivaFilter class]]){
      [component show];
    }
  }
}

- (NSDictionary *) defaultOptions
{
  NSMutableDictionary *allOptions = [NSMutableDictionary dictionary];

  //add components options
  Class cl;
  id dict;
  NSArray *ar = [NSArray arrayWithObjects: @"TimeInterval",
                                           @"GraphConfiguration", nil];
  NSEnumerator *en = [ar objectEnumerator];
  id className;
  while ((className = [en nextObject])){
    cl = [[self loadTrivaBundleNamed: className] principalClass];
    dict = [cl defaultOptions];
    [allOptions addEntriesFromDictionary: dict];
  }

  //add triva options
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *file = [bundle pathForResource: @"Triva" ofType: @"plist"];
  [allOptions addEntriesFromDictionary:
                 [NSDictionary dictionaryWithContentsOfFile: file]];
  return allOptions;
}
@end

@implementation TrivaTreemapController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       TypeFilter, \
       TimeIntegration, \
       SpatialIntegration, \
       SquarifiedTreemap \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end

@implementation TrivaGraphController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       TimeIntegration, \
       GraphConfiguration, \
       GraphView \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end

@implementation TrivaLinkController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];
  NSArray *graph = [@"(  \
    ( FileReader, \
      PajeEventDecoder, \
      PajeSimulator, \
      StorageController, \
      TimeInterval, \
      TimeIntegration, \
      LinkView \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end

@implementation TrivaDotController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Dot \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end

@implementation TrivaCheckController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       CheckTrace \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end

@implementation TrivaListController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       List \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end

@implementation TrivaInstanceController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Instances \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end

@implementation TrivaStatController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeIntegration, \
       SpatialIntegration, \
       StatTrace \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end
