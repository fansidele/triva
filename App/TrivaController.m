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
+ (id) controllerWithArguments: (struct arguments) arguments
{
  TrivaController *triva = nil;
  //configuring triva
  if (arguments.treemap) {
    triva = [[TrivaTreemapController alloc] init];
  }else if (arguments.graph){
    triva = [[TrivaGraphController alloc] init];
  }else if (arguments.linkview){
    triva = [[TrivaLinkController alloc] init];
  }else if (arguments.hierarchy) {
    triva = [[TrivaDotController alloc] init];
  }else if (arguments.check) {
    triva = [[TrivaCheckController alloc] init];
  }else if (arguments.list) {
    triva = [[TrivaListController alloc] init];
  }else if (arguments.instances) {
    triva = [[TrivaInstanceController alloc] init];
  }else{
    NSException *exception = [NSException exceptionWithName: @"TrivaException"
                   reason: @"No visualization option activated" userInfo: nil];
    [exception raise];
  }

  //pass by trace files
  int i;
  NSMutableArray *array = [NSMutableArray array];
  for (i = 0; i < arguments.input_size; i++){
    [array addObject: [NSString stringWithFormat: @"%s", arguments.input[i]]];
  }
  NSLog (@"Tracefile (%@). Reading.... please wait\n", array);
  [triva setInputFiles: array];
  NSLog (@"End of reading - %@ to %@.", [triva startTime], [triva endTime]);
  [triva setSelectionStartTime: [triva startTime] endTime: [triva endTime]];
  return triva;
}

- (id) init
{
  self = [super init];
  components = [NSMutableDictionary dictionary];
  bundles = [NSMutableDictionary dictionary];

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

- (void) setInputFiles: (NSArray *) files
{
  //reading only the first file by default (subclasses
  //should override this if necessary)
  reader = [self componentWithName:@"FileReader" fromDictionary: components];
  [reader setInputFilename: [files objectAtIndex: 0]];
  while ([self hasMoreData]){
    [self readNextChunk: nil];
  }
  simulator = [self componentWithName:@"PajeSimulator" fromDictionary: components];
  encapsulator = [self componentWithName:@"StorageController" fromDictionary: components];
}
@end

@implementation TrivaTreemapController
- (id) init
{
  self = [super init];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       TypeFilter, \
       TimeSliceAggregation, \
       SquarifiedTreemap \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  return self;
}
@end

@implementation TrivaGraphController
- (id) init
{
  self = [super init];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       TimeSliceAggregation, \
       GraphConfiguration, \
       GraphView \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  return self;
}
@end

@implementation TrivaLinkController
- (id) init
{
  self = [super init];
  NSArray *graph = [@"(  \
    ( FileReader, \
      PajeEventDecoder, \
      PajeSimulator, \
      StorageController, \
      TimeInterval, \
      TimeSliceAggregation, \
      LinkView \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  return self;
}
@end

@implementation TrivaDotController
- (id) init
{
  self = [super init];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       Dot \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  return self;
}
@end

@implementation TrivaCheckController
- (id) init
{
  self = [super init];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       CheckTrace \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  return self;
}
@end

@implementation TrivaListController
- (id) init
{
  self = [super init];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       List \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  return self;
}
@end

@implementation TrivaInstanceController
- (id) init
{
  self = [super init];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Instances \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  return self;
}
@end

@implementation TrivaComparisonController
- (void) x
{

}

- (id) init
{
  self = [super init];
/*
  NSMutableArray *graph = [NSMutableArray array];
  [graph addObject: @"FileReader"];
  [graph addObject: @"PajeEventDecoder"];
  [graph addObject: @"PajeSimulator"];
  [graph addObject: @"StorageController"];
*/

//  NSLog (@"%@", [self createComponentWithName: @"FileReader2"
//                 ofClassNamed: @"FileReader"]);
//  NSLog (@"%@", [self createComponentWithName: @"FileReader1"
//                 ofClassNamed: @"FileReader"]);

  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Instances \
    ) )" propertyList];

/*
  NSLog (@"%@", [self componentWithName: @"FileReader"]);
  NSLog (@"%@", [self componentWithName: @"FileReader"]);
  NSLog (@"%@", [self componentWithName: @"FileReader"]);
*/

/*

  [self addComponentSequences: graph];
  NSLog (@"%@", components);
  [self addComponentSequences: graph];
  NSLog (@"%@", components);
*/

  return self;
}
@end
