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

- (void) defineMajorComponents
{
  reader = [self componentWithName:@"FileReader"];
  simulator = [self componentWithName:@"PajeSimulator"];
  encapsulator = [self componentWithName:@"StorageController"];
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
  [self addComponentSequences: graph];
  [self defineMajorComponents];
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
  [self addComponentSequences: graph];
  [self defineMajorComponents];
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
  [self addComponentSequences: graph];
  [self defineMajorComponents];
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
  [self addComponentSequences: graph];
  [self defineMajorComponents];
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
  [self addComponentSequences: graph];
  [self defineMajorComponents];
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
  [self addComponentSequences: graph];
  [self defineMajorComponents];
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
  [self addComponentSequences: graph];
  [self defineMajorComponents];
  return self;
}
@end

