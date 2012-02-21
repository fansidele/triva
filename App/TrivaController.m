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
#include "../Triva/TrivaFilter.m"

@implementation TrivaController
+ (id) controllerWithConfiguration: (TrivaConfiguration *) configuration
{
  TrivaController *triva = nil;
  TrivaVisualizationComponent comp = [configuration visualizationComponent];

  if (comp&TrivaComparison){
    triva = [[TrivaComparisonController alloc]
              initWithConfiguration: configuration];
  }else if (comp&TrivaMerge){
    NSException *ex;
    [ex = [NSException exceptionWithName: @"TrivaControllerException"
                                  reason: @"Merge Controller is deprecated"
                                userInfo: nil] raise];
//    triva = [[TrivaMergeController alloc]
//              initWithConfiguration: configuration];
  }else{
    if (comp&TrivaSquarifiedTreemap) {
      triva = [[TrivaTreemapController alloc]
                initWithConfiguration: configuration];
    }else if (comp&TrivaGraphView){
      triva = [[TrivaGraphController alloc]
                initWithConfiguration: configuration];
    }else if (comp&TrivaGraphFD){
      triva = [[TrivaGraphFDController alloc]
                initWithConfiguration: configuration];
    }else if (comp&TrivaLinkView){
      triva = [[TrivaLinkController alloc]
                initWithConfiguration: configuration];
    }else if (comp&TrivaHierarchy) {
      triva = [[TrivaDotController alloc]
                initWithConfiguration: configuration];
    }else if (comp&TrivaStat) {
      triva = [[TrivaStatController alloc]
                initWithConfiguration: configuration];
    }else if (comp&TrivaCheck) {
      triva = [[TrivaCheckController alloc]
                initWithConfiguration: configuration];
    }else if (comp&TrivaList) {
      triva = [[TrivaListController alloc]
                initWithConfiguration: configuration];
    }else if (comp&TrivaInstances) {
      triva = [[TrivaInstanceController alloc]
                initWithConfiguration: configuration];
    }else{
      NSException *ex;
      [ex = [NSException exceptionWithName: @"TrivaException"
                                    reason: @"No visualization option activated"
                                  userInfo: nil] raise];
    }
  }
  return triva;
}

- (void) dealloc
{
  [server release];
  [components release];
  [super dealloc];
}

- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super init];
  components = [[NSMutableDictionary alloc] init];
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

- (void) initializeWithConfiguration: (TrivaConfiguration *) configuration
{
NS_DURING
  NSArray *files = [configuration inputFiles];
  NSString *file = [files objectAtIndex: 0];
  NSLog (@"Tracefile (%@). Reading.... please wait\n", file);
  //reading only the first file by default (subclasses
  //should override this if necessary)
  reader = [self componentWithName:@"FileReader" fromDictionary: components];
  [reader setInputFilename: file];
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

  en = [components objectEnumerator];
  while ((component = [en nextObject])){
    if ([component isKindOfClass: [TrivaFilter class]]){
      [component setConfiguration: configuration];
    }
  }

  //open component windows
  en = [components objectEnumerator];
  while ((component = [en nextObject])){
    if ([component isKindOfClass: [TrivaFilter class]]){
      [component show];
    }
  }
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
       SpatialIntegration, \
       GraphConfiguration, \
       GraphView \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithConfiguration: configuration];
  return self;
}
@end

@implementation TrivaGraphFDController
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
       SpatialIntegration, \
       GraphConfiguration, \
       FDGraphView \
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
